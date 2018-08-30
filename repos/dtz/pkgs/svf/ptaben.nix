{ stdenv, svf, llvm, clang, fetchFromGitHub, valgrind, testFSPTA ? false, useValgrind ? false }:

stdenv.mkDerivation rec {
  name = "ptaben-${version}";
  version = "2018-08-28";
  src = fetchFromGitHub {
    owner = "SVF-tools";
    repo = "PTABen";
    rev = "bbbbdd0de712d4efb5171d04b40e66537fc81f35";
    sha256 = "1vf270szpfpcd154hmb709qqwv4fkcq4pb8wy8g8i6v0kz1qi8hw";
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
