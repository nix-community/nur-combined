{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
}:

buildPythonPackage (finalAttrs: {
  pname = "coverage";
  version = "5.5";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-6+eP6aDodDYhdbAjcb377mTY7cQqBEJT3fTufTwVISw=";
  };

  # No tests in archive
  doCheck = false;
  nativeCheckInputs = [ mock ];

  meta = {
    description = "Code coverage measurement for python";
    homepage = "https://coverage.readthedocs.io/";
    license = lib.licenses.bsd3;
  };
})
