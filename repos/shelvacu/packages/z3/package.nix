{
  lib,

  stdenv,
  cmake,
  gnumake,
  python3,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "z3";
  version = "4.15.4";
  nativeBuildInputs = [
    cmake
    gnumake
    python3
  ];

  patches = [ ./pkg-config-fix.patch ];

  src = fetchFromGitHub {
    owner = "Z3Prover";
    repo = "z3";
    rev = "z3-${version}";
    hash = "sha256-eyF3ELv81xEgh9Km0Ehwos87e4VJ82cfsp53RCAtuTo=";
  };

  CMAKE_ARGS = [ "-DCMAKE_BUILD_TYPE=Release" ];

  meta = {
    description = "theorem prover from Microsoft Research";
    homepage = "https://github.com/Z3Prover/z3/wiki";
    license = [ lib.licenses.mit ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "z3";
    platforms = lib.platforms.all;
  };
}
