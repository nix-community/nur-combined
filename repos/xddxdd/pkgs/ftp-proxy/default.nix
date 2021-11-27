{
  lib, stdenv,
  ctags,
  fetchurl,
  ...
} @ args:

stdenv.mkDerivation rec {
  pname = "ftp-proxy";
  version = "2.1.0-beta5";

  src = fetchurl {
    url = "http://www.ftpproxy.org/download/beta/ftpproxy-${version}.tgz";
    sha256 = "1wxrsslv1x5a67x0af7sb87cckcznkxz22fdvigcqihsx1kq6p2r";
  };

  buildPhase = ''
    cd src && make clean && make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ftp.proxy $out/bin/ftp.proxy
  '';
}
