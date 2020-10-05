{ stdenv, fetchgit, pkgconfig, writeText, libX11, ncurses, libXft, harfbuzzFull }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "st";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/st";
    rev = "de6fd85eeb544548ed5ad23a639eedd6af510036";
    sha256 = "1xyrbi857435dln7i6qb9ys2jizv43a2zq6fx4dr8z52ramxzyky";
  };

  nativeBuildInputs = [ pkgconfig ncurses ];
  buildInputs = [ libX11 libXft harfbuzzFull ];

  installPhase = ''
    sed -i '/man/d' Makefile
    sed -i '/tic/d' Makefile
    TERMINFO=$out/share/terminfo make PREFIX=$out install
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/st";
    description = "Luke's fork of the suckless simple terminal (st) with vim bindings and Xresource compatibility.";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
