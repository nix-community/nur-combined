{ lib, stdenv, fetchurl, libX11, libXinerama, libXft, zlib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dmenu";
  version = "3a6bc67fbd6df190b002d33f600a6465cad9cfb8";

  src = fetchFromGitHub {
    owner = "LukeSmithxyz";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-qwOcJqYGMftFwayfYA3XM0xaOo6ALV4gu1HpFRapbFg=";
  };

  buildInputs = [ libX11 libXinerama zlib libXft ];

  postPatch = ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
  '';

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  makeFlags = [ "CC:=$(CC)" ];

  meta = with lib; {
    description = "A generic, highly customizable, and efficient menu for the X Window System";
    homepage = "https://github.com/LukeSmithxyz/dmenu";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
