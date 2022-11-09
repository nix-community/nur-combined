{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake }:

stdenv.mkDerivation rec {
  pname = "libspatialindex";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "libspatialindex";
    repo = "libspatialindex";
    rev = version;
    hash = "sha256-zsvS0IkCXyuNLCQpccKdAsFKoq0l+y66ifXlTHLNTkc=";
  };

  patches = [
    # Allow building static libs
    (fetchpatch {
      name = "fix-static-lib-build.patch";
      url = "https://github.com/libspatialindex/libspatialindex/commit/caee28d84685071da3ff3a4ea57ff0b6ae64fc87.patch";
      hash = "sha256-nvTW/t9tw1ZLeycJY8nj7rQgZogxQb765Ca2b9NDvRo=";
    })
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DSIDX_BUILD_TESTS=ON"
  ];

  # FIXME: enable tests
  # Tests error message:
  # 1/1 Test #1: libsidxtest ......................***Failed    0.00 sec
  # /build/source/build/bin/libsidxtest: error while loading shared libraries: libspatialindex_c.so.6: cannot open shared object file: No such file or directory
  doCheck = false;

  meta = with lib; {
    description = "Extensible spatial index library in C++";
    homepage = "https://libspatialindex.org";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
