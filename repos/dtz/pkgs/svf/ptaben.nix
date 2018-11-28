{ stdenv, svf, llvm, clang, fetchFromGitHub, valgrind, testFSPTA ? false, useValgrind ? false }:

stdenv.mkDerivation rec {
  name = "ptaben-${version}";
  version = "2018-11-19";
  src = fetchFromGitHub {
    owner = "SVF-tools";
    repo = "PTABen";
    rev = "bb72be390d15f33d0a00e1b7fcf52bfec1aa94af";
    sha256 = "0h6iz29275c199przvz3z6a7m3rckmk487mpbhiy135rpx8wvh14";
  };

  buildInputs = [ svf llvm clang ];

  configurePhase = ''
    export CLANG=${clang}/bin/clang
    export CLANGCPP=${clang}/bin/clang++
    export LLVMOPT=${llvm}/bin/opt
    export LLVMDIS=${llvm}/bin/llvm-dis
    export LLVMLLC=${llvm}/bin/llc
    export PTABIN=${svf}/bin
    export PTALIB=${svf}/lib
    export PTAHOME=$PWD
    export PTATESTSCRIPTS=$PTAHOME/scripts
    export RUNSCRIPT=$PTATESTSCRIPTS/run.sh
    export PLATFORM=linux
  '';

  hardeningDisable = [ "all" ];

  # https://github.com/unsw-corg/PTABen/issues/2
  patchPhase = stdenv.lib.optionalString testFSPTA ''
    substituteInPlace runtest.sh --replace 'fi_tests' 'fs_tests'
  '' + stdenv.lib.optionalString useValgrind ''
    substituteInPlace scripts/run.sh --replace '$EXEFILE' '${valgrind}/bin/valgrind $EXEFILE'
  '';

  buildPhase = ''
    ./runtest.sh |& tee test.log
  '';

  installPhase = ''
    mkdir $out
    mv test.log $out
  '';

  meta = with stdenv.lib; {
    description = "Micro-benchmark Suite for Pointer Analysis";
    maintainers = with maintainers; [ dtzWill ];
  };
}
