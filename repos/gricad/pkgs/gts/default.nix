{ fetchurl, stdenv, pkgconfig, autoreconfHook, gettext, glib }:


stdenv.mkDerivation rec {
  pname = "gts";
  version = "121130";

  src = fetchurl {
    url = "http://gts.sourceforge.net/tarballs/gts-snapshot-${version}.tar.gz";
    sha256 = "0fxpd70gvvjfaiq9ph895bnf3avg6gb9kdf0z2cmbxmvfjmp4gy2";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook ];
  buildInputs = [ gettext ];
  propagatedBuildInputs = [ glib ];

  doCheck = false; # fails with "permission denied"

  meta = {
    homepage = "http://gts.sourceforge.net/";
    license = stdenv.lib.licenses.lgpl2Plus;
    description = "GNU Triangulated Surface Library";

    longDescription = ''
      Library intended to provide a set of useful functions to deal with
      3D surfaces meshed with interconnected triangles.
    '';

    maintainers = [ stdenv.lib.maintainers.viric ];
    platforms = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
  };
}
