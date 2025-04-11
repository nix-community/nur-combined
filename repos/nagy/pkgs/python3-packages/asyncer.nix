{
  lib,
  fetchPypi,
  buildPythonPackage,
  anyio,
  poetry-core,
  typing-extensions,
  pdm-backend,
}:

buildPythonPackage rec {
  pname = "asyncer";
  version = "0.0.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pYnZgPV+IO+wftkdDb5n8dL9ND5xQsZtOgmfBcYgc5w=";
  };

  propagatedBuildInputs = [
    poetry-core
    anyio
    typing-extensions
    pdm-backend
  ];

  pythonImportsCheck = [ "asyncer" ];

  meta = {
    description = "Asyncer, async and await, focused on developer experience";
    homepage = "https://github.com/tiangolo/asyncer";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
