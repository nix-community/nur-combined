{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pytest-skip-markers";
  version = "1.5.1";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "saltstack";
    repo = "pytest-skip-markers";
    rev = version;
    hash = "sha256-jrNPF68sKpEmwU12ZbKK/24DqA1RrjIXYPyoKE/3FLM=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeBuildInputs = with python3Packages; [
    setuptools-scm
    setuptools-declarative-requirements
  ];

  propagatedBuildInputs = with python3Packages; [
    attrs
    distro
    pytest
  ];

  doCheck = false;

  meta = {
    description = "A Pytest plugin which implements a few useful skip markers";
    inherit (src.meta) homepage;
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
