{ stdenv, fetchFromGitHub, fetchgit, cmake
, python
, git
# http://llnl.github.io/Caliper/build.html
# WITH_FORTRAN	Build Fortran test cases and install Fortran wrapper module.
# WITH_TOOLS	Build cali-query, cali-graph, and cali-stat tools.
# BUILD_DOCS	Enable documentation builds.
# BUILD_TESTING	Build unit test infrastructure and programs.
, gfortran
#Service	Provides	Depends on
#callpath	Call path information	libunwind
, libunwind
#cupti	CUDA driver/runtime calls	CUDA, CUpti
#libpfm	Linux perf_event sampling	Libpfm
, libpfm
#mpi	MPI rank and function calls	MPI
#mpit	MPI tools interface: MPI-internal counters	MPI
, openmpi
, mpi ? openmpi
#ompt	OpenMP thread and status	OpenMP tools interface
#papi	PAPI hardware counters	PAPI library
, papi
#sampler	Time-based sampling	x64 Linux
#symbollookup	Lookup file/line/function info from program addresses	Dyninst
, dyninst
#nvprof	NVidia NVProf annotation bindings	CUDA
#vtune	Intel VTune annotation bindings	VTune
}:

## Service	CMake flags
## callpath	WITH_CALLPATH=On
## cupti	WITH_CUPTI=On. Set CUpti installation dir in CUPTI_PREFIX.
## libpfm	WITH_LIBPFM=On. Set libpfm installation dir in LIBPFM_INSTALL.
## mpi	WITH_MPI=On. Set MPI_C_COMPILER to path to MPI C compiler.
## mpit	WITH_MPIT=On. MPI must be enabled.
## papi	WITH_PAPI=On. Set PAPI installation dir in PAPI_PREFIX.
## sampler	WITH_SAMPLER=On.
## symbollookup	WITH_DYNINST=On. Set path to DyninstConfig.cmake in Dyninst_DIR.
## nvprof	WITH_NVPROF=On. Set CUPTI installation dir in CUPTI_PREFIX.
## vtune	WITH_VTUNE=On. Set Intel ITT API installation dir in ITT_PREFIX.
let
  gotcha = fetchgit {
    url = "https://github.com/LLNL/gotcha.git";
    rev = "refs/tags/1.0.2";
    sha256 = "0p6x751cpmzkv9w51w1r1ifli1s7jjr2rxzmbpaxbi51damq3yf8";
    leaveDotGit = true;
  };

  googletest = fetchgit {
    url = "https://github.com/google/googletest.git";
    rev = "release-1.8.0";
    sha256 = "0jcklc9kwm1jdb9rb2fykyl8sbcgl4g0xhz0qw87gh43pzxly6k5";
    leaveDotGit = true;
  };

in

stdenv.mkDerivation {
  name = "caliper-1.7.0-24-g0c24886";
  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "caliper";
    rev = "0c24886";
    sha256 = "0vj0fnk981bagg73m83m39axpy00dxxdx9hjc79znadfpvwf7lp2";
  };
  buildInputs = [ gfortran libunwind libpfm mpi papi dyninst ];
  nativeBuildInputs = [ cmake python git ];

  preConfigure = ''
    sed -i -e 's@GIT_REPOSITORY    "https://github.com/LLNL/gotcha.git"@GIT_REPOSITORY    "${gotcha}"@' ext/gotcha/gotcha-download_CMakeLists.txt.in
    sed -i -e 's@GIT_TAG           "1.0.2"@GIT_TAG "HEAD"@' ext/gotcha/gotcha-download_CMakeLists.txt.in

    sed -i -e 's@GIT_REPOSITORY    "https://github.com/google/googletest.git"@GIT_REPOSITORY    "${googletest}"@' ext/googletest/googletest-download_CMakeLists.txt.in
    sed -i -e 's@GIT_TAG           "release-1.8.0"@GIT_TAG "HEAD"@' ext/googletest/googletest-download_CMakeLists.txt.in
  '';

  cmakeFlags = [
    "-DWITH_FORTRAN=ON"
    "-DWITH_CALLPATH=ON"
    "-DWITH_LIBPFM=ON"
    "-DWITH_MPI=ON"
    "-DWITH_MPIT=ON"
    "-DWITH_PAPI=ON"
    "-DWITH_SAMPLER=ON"
    "-DWITH_DYNINST=ON"
    "-DBUILD_DOCS=ON"

    ];
}

