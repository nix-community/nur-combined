{ stdenv, fetchFromGitHub, cmake
# Actual build deps
, boost, z3-spacer, llvm, ncurses, gmp, python
# Propagated
, clang
# These are "needed" but not used
, git, subversionClient }:

# OpenMP?

let
  dsa_seahorn = import ./dsa.nix { inherit fetchFromGitHub; };
  llvm_seahorn = import ./llvm.nix { inherit fetchFromGitHub; };
in stdenv.mkDerivation rec {

  name = "seahorn-${version}";
  version = "2017-07-03";

  src = fetchFromGitHub {
    owner = "seahorn";
    repo = "seahorn";
    rev = "000dc4969c8fae677a39df85d5e0d6d3e15c652e";
    sha256 = "05xmqnnkzyagmld87m0jgj1lp9cd5jq2l3jis0w210fgvqr4cjq7";
  };

  buildInputs = [ boost z3-spacer llvm ncurses gmp git subversionClient cmake python ];

  postUnpack = ''
    ln -s ${llvm_seahorn.src} $sourceRoot/llvm-seahorn
    ln -s ${dsa_seahorn.src} $sourceRoot/llvm-dsa
  '';

  patchPhase = ''
    substituteInPlace CMakeLists.txt --replace 3.6.0 3.6.2
  '';

  cmakeFlags = [
    "-DZ3_ROOT=${z3-spacer}"
    "-DLLVM_DIR=${llvm}/share/llvm/cmake"
    # Need static copy of boost-test
    # "-DUNIT_TESTS=ON"
  ];

  postInstall = ''
    cp ${z3-spacer.src}/stats/scripts/z3_smt2.py $out/bin/spacer
    ln -s ${clang}/bin/clang $out/bin/clang-3.6
  '';

  doCheck = false;

  enableParallelBuilding = true;

  passthru = {
    inherit dsa_seahorn llvm_seahorn;
  };
}
