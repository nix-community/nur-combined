# Disclaimer: Some Claude Opus 4.6 was used to write this
{
  lib,
  buildPythonPackage,
  fetchPypi,
  # Build tools
  setuptools,
  setuptools-scm,
  scikit-build-core,
  cmake,
  ninja,
  pybind11,
  # Python deps
  numpy,
  scipy,
  # Native libs
  fftw,
  zlib,
  imath,
  openexr,
  libjpeg,
  libtiff,
  libpng,
  openimageio,
  freetype,
  opencolorio,
  opencv,
  libraw,
  libheif,
  mesa,
  libgbm,
  libglvnd,
  qt6,
  giflib,
  ffmpeg,
  openjph,
  libwebp,
  robin-map,
}:

buildPythonPackage rec {
  pname = "OpenImageIO";
  version = "3.1.10.0";
  pyproject = true;

  src = fetchPypi {
    pname = "openimageio";
    version = "3.1.10.0";
    sha256 = "sha256-XYA5S5YtwPg8FO/Ov8SBw9HtOr5mABsvYCJhzbHJBYo=";
  };

  build-system = [
    setuptools
    setuptools-scm
    scikit-build-core
  ];

  dependencies = [
    numpy
    scipy
  ];

  nativeBuildInputs = [
    fftw
    cmake
    ninja
  ];

  buildInputs = [
    zlib
    imath
    openexr
    libjpeg
    libtiff
    libpng
    openimageio
    freetype
    opencolorio
    opencv
    libraw
    libheif
    mesa
    libgbm
    libglvnd
    qt6.qtbase
    qt6.qttools
    giflib
    ffmpeg
    openjph
    libwebp
    robin-map
    pybind11
  ];

  # The PyPI tarball doesn't ship testsuite/, but CMake references it
  postUnpack = ''
    mkdir -p $sourceRoot/testsuite/common
    touch $sourceRoot/testsuite/runtest.py
  '';

  dontWrapQtApps = true;
  dontUseCmakeConfigure = true;

  # Pass CMake args through scikit-build-core's environment variable
  env.SKBUILD_CMAKE_ARGS = "-DUSE_Nuke=OFF;-DOpenImageIO_BUILD_MISSING_DEPS=none";

  meta = with lib; {
    description = "Python bindings for OpenImageIO";
    homepage = "https://openimageio.readthedocs.io/";
  };
}
