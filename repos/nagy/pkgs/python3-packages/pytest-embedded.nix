{
  lib,
  fetchPypi,
  buildPythonPackage,
  flit-core,
  filelock,
  pexpect,
  pytest,
}:

buildPythonPackage rec {
  pname = "pytest-embedded";
  version = "1.18.2";
  pyproject = true;

  src = fetchPypi {
    pname = "pytest_embedded";
    inherit version;
    hash = "sha256-qz2kEqZW0GJb4W+c3b6z9Bap6MXmmz5Z2uHu4jPfwBU=";
  };

  build-system = [
    flit-core
  ];

  dependencies = [
    filelock
    pexpect
    pytest
  ];

  pythonImportsCheck = [
    "pytest_embedded"
  ];

  meta = {
    description = "Pytest plugin that designed for embedded testing";
    homepage = "https://pypi.org/project/pytest-embedded/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
