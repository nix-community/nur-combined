{ lib, stdenv, fetchurl, makeWrapper, nwjs, unzip }:

stdenv.mkDerivation rec {
  name = "popcorntime";
  version = "0.4.4";

  src = fetchurl {
    url = "https://github.com/popcorn-official/popcorn-desktop/releases/download/v${version}/Popcorn-Time-${version}-linux64.zip";
    sha256 = "fdfabf8800c385bafec4bf162dd26f7df6d8c4c24671dce0aa23997716c5a314";
  };

  dontPatchELF = true;
  sourceRoot   = "./";
  buildInputs  = [ unzip makeWrapper ];

  buildPhase = ''
    rm Popcorn-Time
    cat ${nwjs}/bin/nw nw_100_percent.pak > Popcorn-Time
    chmod 555 Popcorn-Time
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/
    makeWrapper $out/Popcorn-Time $out/bin/popcorntime
  '';

  meta = with stdenv.lib; {
    homepage = https://popcorntime.app/;
    description = "An application that streams movies and TV shows from torrents";
    license = stdenv.lib.licenses.gpl3;
    platforms = platforms.linux;
  };
}
