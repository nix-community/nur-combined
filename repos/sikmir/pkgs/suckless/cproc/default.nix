{
  lib,
  stdenv,
  fetchFromSourcehut,
  qbe,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cproc";
  version = "0-unstable-2024-01-27";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "e96df56b734d0a2619e7690c60a5472449d086c1";
    hash = "sha256-SC/Kn2seS/SLN85K/VXsLFCYXUqdwKjg3KiWkbNdu7I=";
  };

  buildInputs = [ qbe ];

  doCheck = true;

  meta = {
    description = "C11 compiler using QBE as a backend";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
