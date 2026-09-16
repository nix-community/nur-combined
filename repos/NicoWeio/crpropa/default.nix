{ lib
, stdenv
, cmake
, fetchFromGitHub
, gfortran
, hdf5
, numpy
, pkg-config
, python
, swig
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "crpropa";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "CRPropa";
    repo = "CRPropa3";
    rev = finalAttrs.version;
    hash = "sha256-gzdic5uW+HpckleLH2SP2X38AWnhEHUUHKSHc6qiDQ8=";
  };

  nativeBuildInputs = [ cmake gfortran pkg-config python swig ];
  buildInputs = [ hdf5 python zlib ];
  propagatedBuildInputs = [ numpy ];

  cmakeFlags = [
    "-DBUILD_DOC=OFF"
    "-DDOWNLOAD_DATA=OFF"
    "-DENABLE_GIT=OFF"
    "-DENABLE_TESTING=OFF"
    "-DSIMD_EXTENSIONS=none"
    "-DPython_EXECUTABLE=${python.interpreter}"
    "-DPython_ROOT_DIR=${python}"
    "-DPython_INSTALL_PACKAGE_DIR=${placeholder "out"}/${python.sitePackages}"
  ];

  doCheck = false;

  meta = {
    description = "Framework for propagating ultra-high-energy particles through extragalactic space";
    homepage = "https://crpropa.desy.de/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
