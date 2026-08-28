{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage (finalAttrs: {
  pname = "ipaddr";
  version = "2.2.0";
  disabled = isPy3k;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-QJLf5mdYjRaqErWay3yKQCTl3LI6aBzQsLYCNz7KiNY=";
  };

  meta = with lib; {
    description = "Google's IP address manipulation library";
    homepage = "https://github.com/google/ipaddr-py";
    license = licenses.asl20;
  };

})
