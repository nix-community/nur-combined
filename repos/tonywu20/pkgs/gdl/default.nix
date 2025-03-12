{ stdenv
, fetchurl
, openmpi
, plplot
, cmake
, ncurses
, zlib
, libpng
, readline
, gsl
, gcc
, imagemagick
, wxGTK32
, libgeotiff
, netcdf
, hdf5
, python27
, eigen
, graphicsmagick
, fftw
, hdf4
, ntirpc
, proj
, udunits
, glpk
, shapelib
, expat
, clang
}:
let
  my-python-packages = python-packages: with python-packages; [
    numpy
  ];
  python-with-my-packages = python27.withPackages my-python-packages;
in


stdenv.mkDerivation rec {
  version = "1.0.1";
  name = "gdl";

  nativeBuildInputs = [ cmake fftw clang ];

  buildInputs = [
    plplot
    openmpi
    ncurses
    zlib
    libpng
    readline
    gsl
    imagemagick
    wxGTK32
    libgeotiff
    netcdf
    hdf5
    eigen
    graphicsmagick
    python-with-my-packages
    hdf4
    ntirpc
    proj
    udunits
    glpk
    shapelib
    expat
  ];

  src = fetchurl {
    url = "https://github.com/gnudatalanguage/gdl/archive/v${version}.tar.gz";
    sha256 = "0jj7c35fn5wy91sf7fkivrjkcd5kz93x7hlmy5ghgd4nq2zml1gb";
  };

  cmakeFlags = [
    "-DHDF=OFF"
    "-DFFTW=OFF"
    "-DPSLIB=OFF"
    "-DRPCDIR=${ntirpc}"
    "-DRPC_INCLUDE_DIR=${ntirpc}/include/ntirpc"
    "-DRPC_LIBRARY=${ntirpc}/lib"
    "-DINTERACTIVE_GRAPHICS=OFF"
    "-DGRIB=OFF"
  ];

  hardeningDisable = [ "all" ];

  meta = {
    description = "A free and open-source IDL/PV-WAVE compiler";
    homepage = "https://github.com/gnudatalanguage/gdl";
    broken = true;
  };

}
