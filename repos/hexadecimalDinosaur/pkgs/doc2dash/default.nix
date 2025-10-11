{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  hatchling,
  hatch-vcs,
  hatch-fancy-pypi-readme,
  attrs,
  beautifulsoup4,
  click,
  markdown-it-py,
  mdurl,
  pygments,
  rich,
  soupsieve,
  typing-extensions,
  coverage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "doc2dash";
  version = "3.1.0";

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "doc2dash";
    tag = version;
    hash = "sha256-u6K+BDc9tUxq4kCekTaqQLtNN/OLVc3rh14sVSfPtoQ=";
  };

  pyproject = true;
  build-system = [
    hatchling
    hatch-vcs
    hatch-fancy-pypi-readme
  ];

  pythonImportsCheck = [ "doc2dash" ];

  dependencies = [
    attrs
    beautifulsoup4
    click
    markdown-it-py
    mdurl
    pygments
    rich
    soupsieve
    typing-extensions
  ];

  nativeCheckInputs = [
    coverage
    pytestCheckHook
  ];

  meta = {
    description = "Convert docs to the docset format";
    homepage = "https://doc2dash.hynek.me/en/stable/";
    changelog = "https://github.com/hynek/doc2dash/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
