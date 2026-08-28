{
  lib,
  buildPythonPackage,
  fetchPypi,
  unittest2,
}:

buildPythonPackage (finalAttrs: {
  pname = "contextlib2";
  version = "0.6.0.post1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-AfSQCYwYsZ0r1btdxEWyBU0vqX8JpCgLosXzw5TIFi4=";
  };

  checkInputs = [ unittest2 ];

  meta = {
    description = "Backports and enhancements for the contextlib module";
    homepage = "https://contextlib2.readthedocs.org/";
    license = lib.licenses.psfl;
  };
})
