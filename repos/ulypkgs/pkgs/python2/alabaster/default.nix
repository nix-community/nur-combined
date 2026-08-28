{
  lib,
  buildPythonPackage,
  fetchPypi,
  pygments,
}:

buildPythonPackage (finalAttrs: {
  pname = "alabaster";
  version = "0.7.12";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-pmHXLVjm6opX96huN9hnFoY+5ekniDmFJtWLJqTk3AI=";
  };

  propagatedBuildInputs = [ pygments ];

  # No tests included
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/bitprophet/alabaster";
    description = "A Sphinx theme";
    license = licenses.bsd3;
  };
})
