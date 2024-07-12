{ lib, fetchgit, stdenv,
  gmp,
  cmake, gnum4, nasm,
  ... }:
let
  version = "0.0.3";
  src = fetchgit {
    rev = "v${version}";
    url = "https://github.com/iden3/rapidsnark.git";
    hash = "sha256-JH+/4TE7oSDpcUFvKbmgwSAi4xDOZLabUFQ7VX6BH4Q";
    deepClone = true;
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
