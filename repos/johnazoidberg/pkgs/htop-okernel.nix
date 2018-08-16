{ lib, fetchFromGitHub, stdenv, python, ncurses, libtool, gettext, autoconf, automake, pkgconfig }:

stdenv.mkDerivation rec {
  name = "htop-${version}";
  version = "2.2.0-okernel";

  src = fetchFromGitHub {
    owner ="JohnAZoidberg";
    repo = "htop";
    rev = "okernel";
    sha256 = "001smsl8kij0xb24yfw616x1n18cxvma465dpjmnjk1sbyxi4cih";
  };

  preConfigure = ''
    ./autogen.sh
  '';

  nativeBuildInputs = [ python libtool gettext autoconf automake pkgconfig ];
  buildInputs = [ ncurses ];

  prePatch = ''
    patchShebangs scripts/MakeHeader.py
  '';

  meta = with stdenv.lib; {
    description = "An interactive process viewer for Linux";
    homepage = https://hisham.hm/htop/;
    license = licenses.gpl2Plus;
    platforms = with platforms; linux ++ freebsd ++ openbsd ++ darwin;
    maintainers = with maintainers; [ rob relrod ];
    priority = -1;  # override default htop
  };
}
