{ lib, fetchFromGitHub, stdenv,
  gmp,
  cmake, gnum4, nasm,
  ... }:
let
  version = "0.0.3";
  src = fetchFromGitHub {
    rev = "b17e6fed08e9ceec3518edeffe4384313f91e9ad";
    owner = "iden3";
    repo = "rapidsnark";
    hash = "sha256-23h06Q6vk4rfKO8VwD7Y+Gu6HcSzG0GXSxNeG3agW6k=";
    fetchSubmodules = true;
    leaveDotGit = false;
  };
  buildInputs = [ gmp ];
  nativeBuildInputs = [ cmake gnum4 nasm ];
in
stdenv.mkDerivation {
  inherit version buildInputs nativeBuildInputs;
  pname = "rapidsnark";
  srcs = [ src ];
  patches = [ ./patches/CMakeLists_dont_install_gmp.patch ];
  doCheck = true;
  checkPhase = "./src/test_prover";
  cmakeFlags = ["-DCMAKE_BUILD_TYPE=Release"];

  meta = {
    description = "rapidsnark is a fast zkSNARK prover written in C++, that generates proofs for circuits created with circom and snarkjs.";
    homepage = "https://github.com/iden3/rapidsnark";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
