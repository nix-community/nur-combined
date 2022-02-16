{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "libetc";
  version = "0.4";

  src = fetchzip {
    url = "https://ordiluc.net/fs/libetc/libetc-${version}.tar.gz";
    sha256 = "10n2sxmiglpxh0gdmbib3fa8qyfm5ci75k964xqszs7ay8wa36d4";
  };

  makeFlags = [ "LIBDIR=${placeholder "out"}/lib" ];

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
