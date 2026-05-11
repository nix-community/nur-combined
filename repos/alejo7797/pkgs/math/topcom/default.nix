{
  stdenv,
  lib,
  autoreconfHook,
  fetchurl,
  fetchpatch,

  gmp,
  cddlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "topcom";
  version = "1.1.2";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchurl {
    url = "https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM-Downloads/TOPCOM-${
      builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }.tgz";
    hash = "sha256-T7EHVO5bdgVkQf6pjyyN7l228phNjBQoO0kjmtQ3irY=";
  };

  patches = [
    (fetchpatch {
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/topcom/-/raw/67c9a20c8e1597898f3950b486b4287641823363/system-libs.patch";
      hash = "sha256-F+1ZtluGL3i+LKWp0poQnx2ZlV5TSp6WSK5yl2FmOP4";
    })
  ];

  postPatch = ''
    substituteInPlace {,lib-}src{,-reg}/Makefile.am \
      --replace-fail '$(includedir)/cddlib' '${lib.getDev cddlib}/include/cddlib'
  '';

  enableParallelBuilding = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    gmp
    cddlib
  ];

  meta = {
    description = "Compute Triangulations Of Point Configurations and Oriented Matroids";
    license = lib.licenses.gpl3Plus;
    homepage = "https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM/";
  };
})
