{
  lib,
  stdenv,
  fetchFromSourcehut,
  qbe,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cproc";
  version = "0-unstable-2024-04-27";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "f66a661359a39e10af01508ad02429517b8460e3";
    hash = "sha256-MsZSfaX/aUZ7YqsfGzWJc0Wnsjpt24CWA6z16/PYRXs=";
  };

  buildInputs = [ qbe ];

  doCheck = true;

  meta = {
    description = "C11 compiler using QBE as a backend";
    homepage = "https://sr.ht/~mcf/cproc";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
