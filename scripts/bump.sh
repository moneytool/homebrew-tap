#!/usr/bin/env bash
# Point Formula/ecsodus.rb at a new ecsodus release on PyPI and regenerate every resource block.
#
#   scripts/bump.sh 0.2.1
#
# What it does:
#   1. reads the sdist URL and sha256 for ecsodus==<version> from the PyPI JSON API;
#   2. resolves the full runtime dependency set with the same interpreter the formula uses
#      (Homebrew's python@3.14) via `pip install --dry-run --report`, i.e. the method
#      `brew update-python-resources` uses, without its "uploaded at least a day ago" filter,
#      so it works on release day;
#   3. rewrites url/sha256 and replaces all `resource` blocks with pinned sdists (alphabetical).
#
# It only edits the formula file. Review the diff, then run `brew style`, `brew audit` and a
# local install + test before committing (see README.md).
set -euo pipefail

version="${1:?usage: scripts/bump.sh <version>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
formula="$root/Formula/ecsodus.rb"

python="${PYTHON:-}"
if [[ -z "$python" ]]; then
  python="$(brew --prefix python@3.14 2>/dev/null)/libexec/bin/python"
fi
[[ -x "$python" ]] || { echo "error: no python at $python (brew install python@3.14 or set PYTHON=)" >&2; exit 1; }

"$python" - "$version" "$formula" <<'PY'
import json, re, subprocess, sys, urllib.request

version, formula = sys.argv[1], sys.argv[2]

def sdist(name, ver):
    with urllib.request.urlopen(f"https://pypi.org/pypi/{name}/{ver}/json") as r:
        data = json.load(r)
    files = [u for u in data["urls"] if u["packagetype"] == "sdist"]
    if len(files) != 1:
        sys.exit(f"error: expected exactly one sdist for {name}=={ver}, found {len(files)}")
    return files[0]["url"], files[0]["digests"]["sha256"]

def canon(name):
    return re.sub(r"[-_.]+", "-", name).lower()

url, sha = sdist("ecsodus", version)

report = json.loads(subprocess.run(
    [sys.executable, "-m", "pip", "install", "-q", "--disable-pip-version-check", "--dry-run",
     "--ignore-installed", "--report", "-", f"ecsodus=={version}"],
    check=True, capture_output=True, text=True).stdout)
deps = sorted(
    (canon(i["metadata"]["name"]), i["metadata"]["version"])
    for i in report["install"]
    if canon(i["metadata"]["name"]) != "ecsodus"
)

blocks = []
for name, ver in deps:
    r_url, r_sha = sdist(name, ver)
    blocks.append(f'  resource "{name}" do\n    url "{r_url}"\n    sha256 "{r_sha}"\n  end\n')
resources = "\n".join(blocks)

src = open(formula).read()
src = re.sub(r'^  url ".*"$', f'  url "{url}"', src, count=1, flags=re.M)
src = re.sub(r'^  sha256 ".*"$', f'  sha256 "{sha}"', src, count=1, flags=re.M)
# Replace the contiguous run of resource blocks (first `resource` .. last `end` before `def install`).
src, n = re.subn(r'(?ms)^  resource ".*?^  end\n(?=\n  def install)', resources, src, count=1)
if n != 1:
    sys.exit("error: could not locate the resource blocks in the formula")
open(formula, "w").write(src)

print(f"ecsodus {version}: {url}")
print(f"{len(deps)} resources: " + ", ".join(f"{n}=={v}" for n, v in deps))
PY
