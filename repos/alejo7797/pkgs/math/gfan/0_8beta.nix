{
  lib,
  stdenv,
  fetchurl,
  cddlib,
  gmp,
  onetbb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfan";
  version = "0.8beta";

  src = fetchurl {
    url = "https://users-math.au.dk/jensen/software/gfan/gfan${finalAttrs.version}.tar.gz";
    hash = "sha256-+niE5fMXxQ+PtPN7z11Bnw/V97kNYDc0nRlX6nPOu+4=";
  };

  patches = [
    ./cddlib-prefix.patch
  ];

  buildInputs = [
    cddlib
    gmp
    onetbb
  ];

  enableParallelBuilding = true;

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  doCheck = true;

  meta = {
    description = "Software package for computing Gröbner fans and tropical varieties";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    homepage = "http://users-math.math.au.dk/jensen/software/gfan/gfan.html";
  };
})
