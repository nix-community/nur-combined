# based on https://github.com/NixOS/nixpkgs/pull/423815

{
  fetchFromGitHub,
  lib,
  patchelf,

  buildPythonApplication,

  hatchling,

  bashlex,
  bracex,
  build,
  certifi,
  dependency-groups,
  filelock,
  humanize,
  packaging,
  platformdirs,
  pyelftools,
  wheel,

  pytestCheckHook,
  xdoctest,

  jinja2,
  pytest-timeout,
  pytest-xdist,
  pytest-rerunfailures,
  setuptools,
  tomli-w,
  validate-pyproject,
}:

buildPythonApplication rec {
  pname = "cibuildwheel";
  version = "3.4.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pypa";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-1WafHpqT6ME0sQdm/MkQuKt5ABj6YM587XeBDAz9TiM=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    bashlex
    bracex
    build
    certifi
    dependency-groups
    filelock
    humanize
    packaging
    platformdirs
    pyelftools
    wheel
  ];

  # prefer non-wheel distribution
  pythonRemoveDeps = [ "patchelf" ];

  propagatedBuildInputs = [ patchelf ];

  nativeCheckInputs = [
    pytestCheckHook
    xdoctest
  ];

  checkInputs = [
    filelock
    jinja2
    pytest-timeout
    pytest-xdist
    pytest-rerunfailures
    setuptools
    tomli-w
    validate-pyproject
  ];

  # tests write to ~/.cache and TMPDIR is neatly cleaned up afterwards
  preCheck = "export HOME=$TMPDIR";

  # there's also a `tests` folder with integration tests
  # but we can't / don't want to run these from the build sandbox
  enabledTestPaths = [ "unit_test" ];

  disabledTestPaths = [ "unit_test/download_test.py" ];

  pythonImportsCheck = [ "cibuildwheel" ];

  meta = {
    description = "Build Python wheels for all the platforms with minimal configuration";
    homepage = "https://github.com/pypa/cibuildwheel";
    changelog = "https://github.com/pypa/cibuildwheel/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [
      jemand771
    ];
    mainProgram = "cibuildwheel";
  };
}
