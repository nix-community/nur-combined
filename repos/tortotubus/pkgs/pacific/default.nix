{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gnumake,
  gcc,
  openmpi,
  hdf5-mpi,
  zlib,
  xercesc,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "pacific";
  version = "0.0.1";

  # Build the current source tree (this repo checkout)
  src = fetchFromGitHub {
    owner = "tortotubus";
    repo = "PacIFiC";
    rev = "2f26363b1f18bb4ca6bca9964b6d679b6fb0a777";
    hash = "sha256-aRdoKZGOr+nhRwuUHFytxhNSJo6QTKObnVwUqReCBYo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    gcc
    cmake
    gnumake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    xercesc
    zlib
    (hdf5-mpi.override { mpi = openmpi; })
    openmpi
  ];

  propagatedBuildInputs = [
    xercesc
    zlib
    (hdf5-mpi.override { mpi = openmpi; })
    openmpi
  ];

  cmakeFlags = [
    # "-DCMAKE_C_COMPILER=${openmpi}/bin/mpicc"
    # "-DCMAKE_CXX_COMPILER=${openmpi}/bin/mpicxx"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_SUBMODULES=ON"
    "-DOCTREE_BASILISK_PROVIDER=VENDORED"
  ];

  # Optional: ensure mpirun is available when running the installed executables
  # postFixup = ''
  #   for p in $out/bin/*; do
  #     [ -x "$p" ] || continue
  #     wrapProgram "$p" --prefix PATH : ${lib.makeBinPath [ openmpi ]}
  #   done
  # '';

  meta = with lib; {
    description = "PacIFiC multiphysics toolkit";
    homepage = "https://github.com/tortotubus/PacIFiC";
    platforms = platforms.linux;
    license = licenses.mit;
    mainProgram = "grains";
  };
}
