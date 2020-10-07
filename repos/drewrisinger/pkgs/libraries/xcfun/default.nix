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
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "dftlibs";
    repo = pname;
    rev = "v${version}";
    sha256 = "1gnc3x7x7w0qigyr6h8m877bwrkjfd7b300f6cq535pr98ksmpx2";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    bzip2
    gfortran
    perl
  ];

  # TODO: Remove on next release,
  patches = [
    (fetchpatch {
      name = "xcfun-fix-header-file-install.patch";
      url = "https://github.com/dftlibs/xcfun/commit/8eb400ee160e9ba013fa9a4fb23d55bb2a1d2f8f.patch";
      sha256 = "17rb0sy93yz61v0hk2a1qd81ljscvw6j7jhnw8zvypdpfkc6qysl";
    })
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
