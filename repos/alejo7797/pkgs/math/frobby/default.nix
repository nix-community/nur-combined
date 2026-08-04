{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  gmp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "frobby";
  version = "0.9.9";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "Macaulay2";
    repo = "frobby";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LndLfORnypLqFgNMPEJ8jc2Fa2xWWgYS9rZ7gGFbwwo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gmp
  ];

  meta = {
    description = "Computations with monomial ideals";
    license = lib.licenses.gpl2Plus;
    homepage = "https://github.com/Macaulay2/frobby/";
    mainProgram = "frobby";
  };
})
