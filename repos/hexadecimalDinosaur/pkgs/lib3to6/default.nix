{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  pythonAtLeast,
  setuptools,
  wheel,
  pathlib2,
  astor,
  click,
  pytestCheckHook,
  pytest-cov,
}:


buildPythonPackage rec {
  pname = "lib3to6";
  version = "202107.1047";

  src = fetchFromGitHub {
    owner = "mbarkhau";
    repo = "lib3to6";
    tag = "v${version}";
    hash = "sha256-eDACwTnLtLaqL+eHNA/q1DiMzkg6/UXwkdsrPTYRJlc=";
  };

  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];
  disabled = (pythonOlder "3.6") || (pythonAtLeast "3.14");

  dependencies = [
    pathlib2
    astor
    click
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov
  ];
  disabledTestPaths = [
    "scripts/exit_0_if_empty.py"
  ];

  meta = {
    description = "Build universally compatible python packages from a substantial subset of Python 3.8";
    homepage = "https://github.com/mbarkhau/lib3to6";
    changelog = "https://github.com/mbarkhau/lib3to6/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "lib3to6";
  };
}
