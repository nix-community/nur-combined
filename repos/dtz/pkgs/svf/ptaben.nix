{ stdenv, svf, llvm, clang, fetchFromGitHub, valgrind, testFSPTA ? false, useValgrind ? false }:

stdenv.mkDerivation rec {
  name = "ptaben-${version}";
  version = "2018-12-05";
  src = fetchFromGitHub {
    owner = "SVF-tools";
    repo = "PTABen";
    rev = "8648e3eb511c4ddf970eb5d8fbcdcf1e70a23019";
    sha256 = "0jxs59w0f9sf37l4qa14ma4ypb5ga5dvknac0yl7xim0ma5z2fk9";
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
