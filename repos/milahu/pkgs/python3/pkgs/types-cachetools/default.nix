{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-cachetools";
  version = "6.2.0.20251022";
  pyproject = true;

  src = fetchPypi {
    pname = "types_cachetools";
    inherit version;
    hash = "sha256-8dPHNvD3QeiewQ8OGwE4YlAj4h6zNgOpMMFJ4DGMDO8=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "types_cachetools"
  ];

  meta = {
    description = "Typing stubs for cachetools";
    homepage = "https://pypi.org/project/types-cachetools/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
