{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "itsdangerous";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-MhsDPQfypBNtPsdi6snxahDM1g9TwMka+QIXrOe6Hxk=";
  };

  meta = with lib; {
    description = "Helpers to pass trusted data to untrusted environments and back";
    homepage = "https://pypi.python.org/pypi/itsdangerous/";
    license = licenses.bsd0;
  };

})
