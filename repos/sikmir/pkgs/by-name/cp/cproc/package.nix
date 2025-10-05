{
  lib,
  stdenv,
  fetchFromSourcehut,
  qbe,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cproc";
  version = "0-unstable-2025-02-11";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "a2ddee1be68e76a1ac7f83b55732be8e54fe08c4";
    hash = "sha256-mQw2lTr/e8f778r69h7w+xg9IqO3UO1FJi6x8H1SbQ4=";
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
