{ lib, stdenv, fetchurl, libX11, libXinerama, libXft, zlib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dmenu";
  version = "575252ee7570512226e1f55b45af0e6676f0bbb6";

  src = fetchFromGitHub {
    owner = "LukeSmithxyz";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-qrnixNjLW0rODgJp/pHil3AkDNCYb/nmyGpKBJvGsJw=";
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
