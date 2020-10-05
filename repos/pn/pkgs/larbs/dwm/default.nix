{ stdenv, fetchgit, libX11, libXinerama, libXft, xlibs, patches ? [] }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "dwm";
  version = "1.0";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/dwm";
    rev = "28d87d439359096e2f03f2e8582a481269de06be";
    sha256 = "1fi0q68zqcmnx4spvjaqlv0k43ij96bz3545qdlc077qhzw2lxxh";
  };

  buildInputs = [ libX11 libXinerama libXft xlibs.libXext.dev ];

  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';

  inherit patches;

  buildPhase = ''make LDFLAGS="-L/usr/X11R6/lib -lX11 -lXinerama -lfontconfig -lXft -lX11-xcb -lxcb -lxcb-res -lXext"'';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/dwm";
    description = "Luke's build of dwm";
    license = stdenv.lib.licenses.mit;
    platforms = with stdenv.lib.platforms; all;
  };
}
