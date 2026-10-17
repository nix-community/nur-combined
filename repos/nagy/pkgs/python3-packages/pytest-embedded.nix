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
  version = "2.9.3";
  pyproject = true;

  src = fetchPypi {
    pname = "pytest_embedded";
    inherit version;
    hash = "sha256-9JkzplMksLJEzDqC+x6SbuOgErQN+tplUIudvHxFERk=";
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
    homepage = "https://github.com/espressif/pytest-embedded";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
