{ stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, gfortran
, perl
, bzip2
}:

stdenv.mkDerivation rec {
  pname = "xcfun";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "dftlibs";
    repo = pname;
    rev = "v${version}";
    sha256 = "1bj70cnhbh6ziy02x988wwl7cbwaq17ld7qwhswqkgnnx8rpgxid";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    bzip2
    gfortran
    perl
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=1"
    "-DBUILD_SHARED_LIBS=1"
    "-DXCFUN_MAX_ORDER=3"
    "-H.."
  ];

  doCheck = true;
  # Add xcfun library in build dir to library path for ctest to find
  preCheck = "export LD_LIBRARY_PATH=$(pwd)/$out/lib:$LD_LIBRARY_PATH";

  meta = with stdenv.lib; {
    description = "Exchange-correlation functionals with arbitrary order derivatives";
    homepage = "https://xcfun.readthedocs.io/en/latest/";
    downloadPage = "https://github.com/dftlibs/xcfun/releases";
    changelog = "https://xcfun.readthedocs.io/en/latest/changelog.html";
    license = licenses.mpl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
