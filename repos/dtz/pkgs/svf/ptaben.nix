{ stdenv, svf, llvm, clang, fetchFromGitHub, valgrind, testFSPTA ? false, useValgrind ? false }:

stdenv.mkDerivation rec {
  name = "ptaben-${version}";
  version = "2018-04-04";
  src = fetchFromGitHub {
    owner = "SVF-tools";
    repo = "PTABen";
    rev = "0f03b24635f16029cde57a1f1989348e2fd6c72b";
    sha256 = "0h24p54v4mplji1cl92rfsk4l4qp8n8q7xl5kv3f44jnf2bnklx0";
  };

  buildInputs = [ svf llvm clang ];

  configurePhase = ''
    export CLANG=${clang}/bin/clang
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
    substituteInPlace scripts/testwpa.sh --replace '-ander' '-fspta'
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
