{ fetchFromGitHub
, stdenv
, lib
, gfortran
, perl
, llvmPackages ? null
, precision ? "double"
, enableAvx ? true
, enableAvx2 ? true
, enableFma ? false # not supported
, amdArch ? "znver2"
, enableMpi ? false
, mpi
}:

with lib;

stdenv.mkDerivation rec {
  pname = "amd-fftw";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "amd";
    repo = "amd-fftw";
    rev = version;
    sha256 = "04dcsw4y2f1fnn4548glwad9c9vgr4l18dw40bj6m95h7sa10vb5";
  };

  patches = [
    # remove mtune=native impurity
    ./mtune.patch
  ];

  outputs = [ "out" "dev" "man" "info" ];
  outputBin = "dev"; # fftw-wisdom

  nativeBuildInputs = [ gfortran ];

  buildInputs = lib.optionals stdenv.cc.isClang [
    # TODO: This may mismatch the LLVM version sin the stdenv, see #79818.
    llvmPackages.openmp
  ] ++ optional enableMpi mpi;

  AMD_ARCH = amdArch;

  configureFlags = # --enable-fma and --enable-avx-128-fma flags are broken
    [ "--enable-shared"
      "--enable-threads"
      "--enable-amd-opt"
    ]
    ++ optional (precision != "double") "--enable-${precision}"
    # all x86_64 have sse2
    # however, not all float sizes fit
    ++ optional (stdenv.isx86_64 && (precision == "single" || precision == "double") )  "--enable-sse2"
    ++ optional enableAvx "--enable-avx"
    ++ optional enableAvx2 "--enable-avx2"
    ++ optionals enableMpi [ "--enable-mpi" "--enable-amd-trans" "--enable-amd-mpifft" ]
    ++ [ "--enable-openmp" ];

  enableParallelBuilding = true;

  checkInputs = [ perl ];

  meta = with lib; {
    description = "Fastest Fourier Transform in the West library optimized for AMD Epyc CPUs";
    homepage = "http://www.fftw.org/";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}

