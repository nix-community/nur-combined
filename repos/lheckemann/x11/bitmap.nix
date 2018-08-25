{ stdenv, fetchurl, pkgconfig, libX11, libXmu, libXaw, xbitmaps }:
let
  version = "1.0.8";
  name = "bitmap-${version}";
in stdenv.mkDerivation {
  inherit name;
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libX11 libXmu libXaw xbitmaps ];
  configureFlags = [ "--with-appdefaultdir=$out/share/X11" ];
  src = fetchurl {
    url = "https://xorg.freedesktop.org/archive/individual/app/${name}.tar.bz2";
    sha256 = "0pf31rj8fn61frdbqmqsxwr4ngidz1m6rk78468vlrjl1ywdwv40";
  };
}
