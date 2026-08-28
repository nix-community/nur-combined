{
  lib,
  buildPythonPackage,
  fetchPypi,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinxcontrib-websupport";
  version = "1.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-FQG++w/fHRwpqAD9v0713FNpN3MA3b3RbSzUDlTG7vw=";
  };

  propagatedBuildInputs = [ six ];

  doCheck = false;

  meta = {
    description = "Sphinx API for Web Apps";
    homepage = "http://sphinx-doc.org/";
    license = lib.licenses.bsd2;
  };
})
