{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pytest-skip-markers";
  version = "1.5.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "saltstack";
    repo = "pytest-skip-markers";
    tag = finalAttrs.version;
    hash = "sha256-jrNPF68sKpEmwU12ZbKK/24DqA1RrjIXYPyoKE/3FLM=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  build-system = with python3Packages; [
    setuptools-scm
    setuptools-declarative-requirements
  ];

  dependencies = with python3Packages; [
    attrs
    distro
    pytest
  ];

  doCheck = false;

  meta = {
    description = "A Pytest plugin which implements a few useful skip markers";
    homepage = "https://github.com/saltstack/pytest-skip-markers";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
