{ stdenv, lib, gfortran, cmake, fftw, pkgconfig }:

stdenv.mkDerivation rec {
    pname = "tinker";
    version = "8.8.3";

    src = fetchTarball  {
      url = "https://dasher.wustl.edu/tinker/downloads/tinker-${version}.tar.gz";
      sha256= "1c34s5bjb2ravwrk453zhzhl9bngqw5fc9a95fmj4y87yfy497k9";
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
