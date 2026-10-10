# moneytool/homebrew-tap

Homebrew formulae for [moneytool](https://github.com/moneytool) projects.

## Install ecsodus

```bash
brew install moneytool/tap/ecsodus
ecsodus --version
```

Or tap once and install by short name:

```bash
brew tap moneytool/tap
brew install ecsodus
```

## What is ecsodus?

[ecsodus](https://github.com/moneytool/ecsodus) safely migrates AWS Copilot CLI applications to
Terraform-managed Amazon ECS. It reads a Copilot app from AWS with read-only calls, writes Terraform
that adopts the running resources in place (no recreate), patches the CloudFormation stacks to
retain every resource, and emits a readiness report and a step-by-step runbook so the Copilot stacks
can be torn down without touching the live service.

Documentation: <https://moneytool.github.io/ecsodus/>

The formula installs ecsodus from its PyPI sdist into an isolated virtualenv on Homebrew's
`python@3.14`, with every runtime dependency (boto3, botocore, ruamel.yaml, Jinja2 and their
dependencies) pinned as a `resource`.

There are no bottles yet, so `brew install` builds from source. Since 0.2.1, ecsodus builds with
`hatchling` (pure Python), so no compiler toolchain is needed.

Terraform is not a dependency: install it separately
(`brew install hashicorp/tap/terraform`) when you run the generated configuration.

## Updating the formula for a new ecsodus release

Do this after the new version is live on PyPI (the ecsodus release workflow publishes on a
`vX.Y.Z` tag).

1. Bump `url`/`sha256` and regenerate every `resource` block:

   ```bash
   scripts/bump.sh 0.2.1
   git diff Formula/ecsodus.rb
   ```

   The script reads the sdist URL and sha256 from the PyPI JSON API, resolves the full dependency
   set with Homebrew's `python@3.14` (`pip install --dry-run --report`), and rewrites the resource
   blocks with pinned sdists.

   Equivalent manual route, once the release is more than a day old (Homebrew's resolver ignores
   uploads newer than one day):

   ```bash
   brew tap moneytool/tap "$PWD"     # Homebrew only edits formulae inside a tap
   # edit url + sha256 in Formula/ecsodus.rb, then:
   brew update-python-resources moneytool/tap/ecsodus
   ```

   To get the sha256 by hand: `curl -sL <sdist-url> | shasum -a 256`.

2. Check and test locally:

   ```bash
   brew tap moneytool/tap "$PWD"     # skip if already tapped
   brew style moneytool/tap/ecsodus
   brew audit --strict --online moneytool/tap/ecsodus
   brew install --build-from-source moneytool/tap/ecsodus
   brew test moneytool/tap/ecsodus
   brew uninstall ecsodus && brew untap moneytool/tap
   ```

3. Commit (`ecsodus 0.2.1`), open a PR, and merge once the `test` workflow passes. Users pick it
   up with `brew update && brew upgrade ecsodus`.

If Homebrew core moves its default Python (for example to `python@3.15`), change `depends_on`
in the formula and the interpreter path in `scripts/bump.sh` together, then rerun step 1.

## License

Apache-2.0. See [LICENSE](LICENSE).
