{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "libetc";
  version = "0.4";

  src = fetchurl {
    url = "https://ordiluc.net/fs/libetc/libetc-${version}.tar.gz";
    sha256 = "sha256-Pg9eFx2EWsXui+wGAOx/adMJ7ocE2WwiJTRujcLsxp0=";
  };

  makeFlags = [ "LIBDIR=$(out)/lib" ];

  postPatch = ''
    substituteInPlace Makefile --replace 6644 644
    # prevent compiler warning
    sed -i '33i#include <stdlib.h>' libetc.c
  '';

  preInstall = ''
    mkdir -p $out/lib
  '';

  meta = with lib; {
    homepage = "https://ordiluc.net/fs/libetc/";
    description = "https://ordiluc.net/fs/libetc/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
