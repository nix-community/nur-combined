{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "WSGIserver";
  version = "1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03jzmilzxlpilhijd63rc1rnlp6x8xsdnsjmlxc269i0p9g1880j";
  };

  
  doCheck = false;

  meta = with lib; {
    homepage = "https://f.gallai.re/wsgiserver";
    description = "High-speed, production ready, thread pooled, generic WSGI server with SSL support";
    license = licenses.lgpl3Plus;
  };

}
