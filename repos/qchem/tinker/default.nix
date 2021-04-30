{ stdenv, lib, fetchurl, gfortran, cmake, fftw, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "tinker";
  version = "8.8.3";

  src = fetchurl  {
    url = "https://dasher.wustl.edu/tinker/downloads/tinker-${version}.tar.gz";
    sha256= "1m2pb6g9fqqdv2fml5b72zhm40yyb63ya7pf8h5nx69vipy4z1wz";
  };

  preConfigure = ''
    cd source
    cp ../cmake/CMakeLists.txt .
  '';

  nativeBuildInputs = [
    cmake
    gfortran
    pkgconfig
  ];

  buildInputs = [ fftw ];

  postInstall = ''
    mkdir -p $out/share/tinker
    cp -r ../../params $out/share/tinker

    for exe in $(find $out/bin/ -type f -executable -name "*.x"); do
      ln -s $exe $out/bin/$(basename $exe .x)
    done
  '';

  meta = with lib; {
    description = "Software Tools for Molecular Design";
    homepage = "https://dasher.wustl.edu/tinker/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
