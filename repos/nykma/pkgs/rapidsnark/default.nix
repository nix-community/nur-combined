{ lib, fetchFromGitHub, stdenv,
  gmp,
  cmake, gnum4, nasm,
  ... }:
let
  version = "0.0.6";
  src = fetchFromGitHub {
    rev = "3ea6c4d867fab2425ed435555ec84b8e30cb2826";
    owner = "iden3";
    repo = "rapidsnark";
    hash = "sha256-mFaHRpexBmj8Xz99TPiMAuxcvMBdZAU8JvHHlv+XcxU=";
    fetchSubmodules = true;
    leaveDotGit = false;
  };
  buildInputs = [ gmp ];
  nativeBuildInputs = [ cmake gnum4 nasm ];
  hostSystem = stdenv.hostPlatform.system;
in
stdenv.mkDerivation {
  inherit version buildInputs nativeBuildInputs;
  pname = "rapidsnark";
  srcs = [ src ];
  patches = [ ./patches/CMakeLists_dont_install_gmp.patch ];
  doCheck = true;
  checkPhase = "./src/test_prover";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    (lib.optionalString (hostSystem == "aarch64-darwin") "-DTARGET_PLATFORM=macos_arm64")
    (lib.optionalString (hostSystem == "aarch64-linux") "-DTARGET_PLATFORM=arm64_host")
  ];

  meta = {
    description = "rapidsnark is a fast zkSNARK prover written in C++, that generates proofs for circuits created with circom and snarkjs.";
    homepage = "https://github.com/iden3/rapidsnark";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
