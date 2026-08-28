{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
  zipp,
  pathlib2,
  contextlib2,
  configparser,
  isPy3k,
}:

buildPythonPackage (finalAttrs: {
  pname = "importlib-metadata";
  version = "2.1.1";
  format = "setuptools";

  src = fetchPypi {
    pname = "importlib_metadata";
    inherit (finalAttrs) version;
    hash = "sha256-uN6e/ys1+wNzaPKKffHfTmQ29Xj6dEI1BbbGp3jVtd0=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    zipp
  ]
  ++ lib.optionals (!isPy3k) [
    pathlib2
    contextlib2
    configparser
  ];

  # Cyclic dependencies
  doCheck = false;

  pythonImportsCheck = [ "importlib_metadata" ];

  meta = {
    description = "Read metadata from Python packages";
    homepage = "https://importlib-metadata.readthedocs.io/";
    license = lib.licenses.asl20;
  };
})
