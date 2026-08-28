{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "MarkupSafe";
  version = "1.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-KYcukoOXZeVGgou3dUpoxBjZJ80GT9Rwj6uf6ci7EWs=";
  };

  meta = with lib; {
    description = "Implements a XML/HTML/XHTML Markup safe string";
    homepage = "http://dev.pocoo.org";
    license = licenses.bsd3;
    maintainers = with maintainers; [ domenkozar ];
  };

})
