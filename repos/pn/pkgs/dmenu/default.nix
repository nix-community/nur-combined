{ stdenv, fetchgit, libX11, libXinerama, libXft, zlib, patches ? [] }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "dmenu";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/dmenu";
    rev = "89c6680fc5174c028fa692a9112f037d19a1bc72";
    sha256 = "0sxa3z676ip0w87b0zjapx68wpwzc4mkijjxvnpka2vm4qw5hpsl";
  };

  buildInputs = [ libX11 libXinerama zlib libXft ];

  inherit patches;

  postPatch = ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
  '';

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
    sed 's/static const unsigned int \(.*alpha\) = \(.*\);/#define \1 \2/' config.h
  '';

  makeFlags = [ "CC:=$(CC)" ];

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/dmenu";
    description = "dmenu setup for LARBS";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
