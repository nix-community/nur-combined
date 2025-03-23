{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
}:

stdenv.mkDerivation {
  pname = "pngattach";
  version = "0-unstable-2025-03-12";

  src = fetchFromGitHub {
    owner = "skeeto";
    repo = "scratch";
    rev = "cfd49e7f10d6e7771fe5654d639551f9f6e28885";
    hash = "sha256-cEfHobkg37kA/gXDGYL5jDbo/V3P3BX+27b5Iwk+u2E=";
  };

  sourceRoot = "source/pngattach";

  buildInputs = [ zlib ];

  makeFlags = [
    "PREFIX=$(out)"
    "CC:=$(CC)"
  ];

  meta = {
    homepage = "https://github.com/skeeto/scratch/tree/master/pngattach";
    description = "Attach files to a PNG image as metadata";
    license = lib.licenses.unlicense;
  };
}
