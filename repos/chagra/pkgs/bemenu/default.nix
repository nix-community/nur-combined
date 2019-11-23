{ stdenv, fetchFromGitHub, cmake, pkgconfig
, pango, wayland, libxkbcommon }:

stdenv.mkDerivation rec {
  name = "bemenu-2019-04-28";

  src = fetchFromGitHub {
    owner = "cloudef";
    repo = "bemenu";
    rev = "c9d9bcdaf5f4454ea521b1c15452676df1414005";
    sha256 = "1mih2vd2lb8ix3bvb1vxqc13qhck5y3wgz2r4c8lc7gsi9all6sh";
  };

  cmakeFlags = [
    "-DBEMENU_CURSES_RENDERER=OFF"
    "-DBEMENU_X11_RENDERER=OFF"
    "-DBEMENU_WAYLAND_RENDERER=ON"
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ pango wayland libxkbcommon ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A dynamic menu library and client program inspired by dmenu";
    homepage = src.meta.homepage;
    license = with licenses; [ gpl3 lgpl3 ];
    platforms = platforms.linux;
  };
}
