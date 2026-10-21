class Ecsodus < Formula
  include Language::Python::Virtualenv

  desc "Migrate AWS Copilot CLI apps to Terraform-managed ECS"
  homepage "https://moneytool.github.io/ecsodus/"
  url "https://files.pythonhosted.org/packages/e4/bf/aaa9f5362ec2f9573524f1a802a3aaa596b2d4c97fc244d828936851c00c/ecsodus-0.2.3.tar.gz"
  sha256 "316add02b4a30067caaedbe9d350e2770063eabf0c407622ec1e11b72379e635"
  license "Apache-2.0"

  depends_on "python@3.14"

  resource "boto3" do
    url "https://files.pythonhosted.org/packages/cc/20/de5848b0166d8cb6b6e597b299ca10a64ebba3cf9aaab228de1e817ae85e/boto3-1.43.116.tar.gz"
    sha256 "89fa15e7d1788fb17cbd694b034beba57f43f30f58f4506913a5b62220f8ba01"
  end

  resource "botocore" do
    url "https://files.pythonhosted.org/packages/93/98/aff05e8a35f5bb9f6648c6056ecff02a2bd4540ad70a89215db8a0cae758/botocore-1.43.116.tar.gz"
    sha256 "00b1fbfc1c024b56633538385628a1bbc7ab15aca0b5b53e5fe188841d96c8ce"
  end

  resource "jinja2" do
    url "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz"
    sha256 "0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d"
  end

  resource "jmespath" do
    url "https://files.pythonhosted.org/packages/d3/59/322338183ecda247fb5d1763a6cbe46eff7222eaeebafd9fa65d4bf5cb11/jmespath-1.1.0.tar.gz"
    sha256 "472c87d80f36026ae83c6ddd0f1d05d4e510134ed462851fd5f754c8c3cbb88d"
  end

  resource "markupsafe" do
    url "https://files.pythonhosted.org/packages/38/9b/e422a865e1d5d57d0e509b4e0bf1c1a70a7f6382c29a5aa428df994c8bc8/markupsafe-3.0.4.tar.gz"
    sha256 "2e9ad7dd851bf45fab9f75cbff4cb493fee9979e8d8c7c9c3ee119022518edd6"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz"
    sha256 "37dd54208da7e1cd875388217d5e00ebd4179249f90fb72437e91a35459a0ad3"
  end

  resource "ruamel-yaml" do
    url "https://files.pythonhosted.org/packages/c7/3b/ebda527b56beb90cb7652cb1c7e4f91f48649fbcd8d2eb2fb6e77cd3329b/ruamel_yaml-0.19.1.tar.gz"
    sha256 "53eb66cd27849eff968ebf8f0bf61f46cdac2da1d1f3576dd4ccee9b25c31993"
  end

  resource "s3transfer" do
    url "https://files.pythonhosted.org/packages/49/c5/0a5ce655109cb96b8dfad36908a4e108d15f5dc2eff8fbc3146c4312e704/s3transfer-0.19.3.tar.gz"
    sha256 "8326acc3d056d7f7b8a37110c7d2aea41f67e83f6ae79cd3b5fbcca34c726406"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/e3/05/b17359e1cefb4f909b5e40b1b90a496d987258916dbbf88e842c729f510e/urllib3-2.8.0.tar.gz"
    sha256 "63bf2ead4c879426ebf22ef2a781eeb4aa3b4ae798a0435506f8687fd5bb9b63"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "ecsodus #{version}", shell_output("#{bin}/ecsodus --version")

    help = shell_output("#{bin}/ecsodus --help")
    assert_match "inventory", help
    assert_match "generate", help

    # The runtime dependencies must import from the formula's virtualenv.
    system libexec/"bin/python", "-c", "import boto3, jinja2, ruamel.yaml"
  end
end
