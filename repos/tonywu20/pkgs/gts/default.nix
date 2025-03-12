{ fetchurl, lib, stdenv, pkg-config, autoreconfHook, gettext, glib }:


stdenv.mkDerivation rec {
  pname = "gts";
  version = "121130";

  src = fetchurl {
    url = "http://gts.sourceforge.net/tarballs/gts-snapshot-${version}.tar.gz";
    sha256 = "0fxpd70gvvjfaiq9ph895bnf3avg6gb9kdf0z2cmbxmvfjmp4gy2";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [ gettext ];
  propagatedBuildInputs = [ glib ];

  doCheck = false; # fails with "permission denied"

  meta = {
    homepage = "http://gts.sourceforge.net/";
    license = lib.licenses.lgpl2Plus;
    description = "GNU Triangulated Surface Library";

    longDescription = ''
      Library intended to provide a set of useful functions to deal with
      3D surfaces meshed with interconnected triangles.
    '';

    maintainers = [ lib.maintainers.viric ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
