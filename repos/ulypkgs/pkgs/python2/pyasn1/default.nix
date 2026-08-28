{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyasn1";
  version = "0.4.8";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-rvd8n7lKOsWI6HhBIIvexGRHHZhxvVBQoofMmkdc0Lo=";
  };

  meta = with lib; {
    description = "ASN.1 tools for Python";
    homepage = "http://pyasn1.sourceforge.net/";
    license = "mBSD";
    platforms = platforms.unix; # arbitrary choice
  };
})
