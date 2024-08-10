{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  anyio,
  poetry-core,
  typing-extensions,
  pdm-backend,
}:

buildPythonPackage rec {
  pname = "asyncer";
  version = "0.0.7";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1eVj+w9W64e5cleYRwNlik9bvbUv+FGz6O2GTMIAsdI=";
  };

  propagatedBuildInputs = [
    poetry-core
    anyio
    typing-extensions
    pdm-backend
  ];

  pythonImportsCheck = [ "asyncer" ];

  meta = with lib; {
    description = "Asyncer, async and await, focused on developer experience";
    homepage = "https://github.com/tiangolo/asyncer";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
