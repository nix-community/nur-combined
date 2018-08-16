{ stdenv
, cmake
, llvm
#, clang # tests
, fetchFromGitHub
, checkWithOtherPTAs ? false # They don't pass tests but potentially interesting.
, doCheck ? true
}:

let
  llvm_version = if (llvm ? release_version) then llvm.release_version else (builtins.parseDrvName llvm.name).version;
in
stdenv.mkDerivation rec {
  version = "2018-06-12"; # Date of commit used
  name = "dg_llvm${llvm_version}-${version}";
  src = fetchFromGitHub {
    owner = "mchalupa";
    repo = "dg";
    rev = "97191b54a89e7891723fb340df3b78f4739ea437";
    sha256 = "06xca6ybvaz1w80lilvxjpl9ycnd855ird3gcfvfbgzi5ln1zk5l";
  };

  enableParallelBuilding = true;

  dontUseCmakeBuildDir = true;

  prePatch = ''
    patchShebangs .

    substituteInPlace tools/git-version.sh --replace '`git rev-parse --short=8 HEAD`' ${builtins.substring 0 7 src.rev}

    substituteInPlace src/llvm/analysis/PointsTo/PointerSubgraph.cpp \
      --replace 'static_assert(sizeof(Offset::type) == sizeof(uint64_t))' \
                'static_assert(sizeof(Offset::type) == sizeof(uint64_t), "offset type must be uint64_t")'

    # Assertions cause program to abort (!), fix tests by flushing stdio first
    # newer glibc (2.27+) no longer do this.
    substituteInPlace tests/test_assert.c \
      --replace 'assert(0 && "assertion failed");' \
                'fflush(0); assert(0 && "assertion failed");'
  '';

  cmakeFlags = [
    "-DLLVM_ENABLE_ASSERTIONS=ON"
    "-DLLVM_DIR=${llvm}"
  ];

  # Install other utilities as well
  postPatch = ''
    substituteInPlace tools/CMakeLists.txt \
      --replace "install(TARGETS" "install(TARGETS llvm-ps-dump llvm-rd-dump llvm-to-source llvm-pta-compare"
  '';

  inherit doCheck;

  checkPhase = ''
    # Workaround so tests can find the just-built libs before installation
    export LD_LIBRARY_PATH=$PWD/src:$LD_LIBRARY_PATH

    # Run tests in parallel
    export CTEST_PARALLEL_LEVEL=$NIX_BUILD_CORES

    # Don't add magic hardening CFLAGS to clang while testing!
    export hardeningDisable=all

    # Do default tests, ctest stuff but also other things
    make check
  '' + stdenv.lib.optionalString checkWithOtherPTAs ''
    # Try other pointer analysis variants
    for pta in fi fs old; do
      export DG_TESTS_PTA=$pta
      echo "Running tests with DG_TESTS_PTA=$DG_TESTS_PTA..."
      make check
    done
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm ];

  meta = with stdenv.lib; {
    description = "Dependence graph for programs"; #  Generic implementation of dependence graphs with instantiation for LLVM that contains a static slicer for LLVM bitcode";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.mit;

    broken = !stdenv.cc.isClang;
  };
}

