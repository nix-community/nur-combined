{stdenv, fetchurl, openmpi, plplot, cmake, ncurses, zlib ,libpng, readline, gsl, gcc, imagemagick, wxGTK30,libgeotiff, netcdf, hdf5, python27, eigen, graphicsmagick, fftw3, hdf4 }:
let
  my-python-packages = python-packages: with python-packages; [
   numpy
  ]; 
  python-with-my-packages = python27.withPackages my-python-packages;
in


stdenv.mkDerivation rec {
	version ="0.9.9";
	name="gdl";
	nativeBuildInputs =[cmake fftw3 ];
buildInputs = [plplot openmpi ncurses zlib libpng readline gsl imagemagick wxGTK30 libgeotiff netcdf hdf5 eigen graphicsmagick python-with-my-packages hdf4];
	src = fetchurl {
		url = "https://github.com/gnudatalanguage/gdl/archive/v${version}.tar.gz";
		sha256="ad5de3fec095a5c58b46338dcc7367d2565c093794ab1bbcf180bba1a712cf14";
	};
	enableParallelBuilding =true;
	cmakeFlags =[ "-DHDF=OFF" "-DFFTW=OFF" "-DPSLIB=OFF" ];
	meta = {
		description = "A free and open-source IDL/PV-WAVE compiler";
		homepage = "https://github.com/gnudatalanguage/gdl";
                broken = true;
	};

}
