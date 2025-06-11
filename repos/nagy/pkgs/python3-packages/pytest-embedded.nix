{
  lib,
  fetchPypi,
  buildPythonPackage,
  flit-core,
  pexpect,
  pytest,
}:

buildPythonPackage rec {
  pname = "pytest-embedded";
  version = "1.16.0";
  pyproject = true;

  src = fetchPypi {
    pname = "pytest_embedded";
    inherit version;
    hash = "sha256-Fz2PqjSwG43MrcAD4IPf01pV9nD+oBLqIcyzCZa5blY=";
  };

  build-system = [
    flit-core
  ];

  dependencies = [
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
