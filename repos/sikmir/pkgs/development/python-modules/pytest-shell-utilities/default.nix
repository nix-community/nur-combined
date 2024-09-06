{
  lib,
  fetchFromGitHub,
  python3Packages,
  pytest-skip-markers,
}:

python3Packages.buildPythonPackage rec {
  pname = "pytest-shell-utilities";
  version = "1.9.3";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "saltstack";
    repo = "pytest-shell-utilities";
    rev = version;
    hash = "sha256-AzIspaE6eHaG7YcRtuXtYsjwqF2rvO2YRxdiFlWsHuw=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  build-system = with python3Packages; [
    setuptools-scm
    setuptools-declarative-requirements
  ];

  dependencies = with python3Packages; [
    psutil
    pytest-skip-markers
    pytest-subtests
    pytest-helpers-namespace
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "Pytest Shell Utilities";
    homepage = "https://github.com/saltstack/pytest-shell-utilities";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
