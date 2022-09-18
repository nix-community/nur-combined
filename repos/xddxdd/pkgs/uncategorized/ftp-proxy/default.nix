{ lib
, stdenv
, ctags
, fetchurl
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "ftp-proxy";
  version = "1.2.3";

  src = fetchurl {
    url = "http://www.ftpproxy.org/download/ftpproxy-${version}.tgz";
    sha256 = "1rfnwngggjkbd4c5pydm9fa9323spr2pqvkh611hy44aws4gxanz";
  };

  buildPhase = ''
    cd src && make clean && make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ftp.proxy $out/bin/ftp.proxy
  '';

  meta = with lib; {
    description = "ftp.proxy - FTP Proxy Server";
    homepage = "http://www.ftpproxy.org/";
    license = licenses.gpl2;
  };
}
