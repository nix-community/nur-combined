{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pybase62";
  version = "0.6.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-td+lZICFXRWeG+ZFQ1NbJNLDXN0Y1hfxB7734vdBNyI=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "base62"
  ];

  meta = {
    description = "Python module for base62 encoding";
    homepage = "https://pypi.org/project/pybase62";
    license = lib.licenses.bsd2WithViews;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pybase62";
  };
}
