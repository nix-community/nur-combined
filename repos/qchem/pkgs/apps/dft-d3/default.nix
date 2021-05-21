{ lib, stdenv, fetchurl, gfortran } :

stdenv.mkDerivation rec {
  pname = "dft-d3";
  version = "3.2rev0";

  nativeBuildInputs = [ gfortran ];

  src = fetchurl {
    url = "https://www.chemie.uni-bonn.de/pctc/mulliken-center/software/dft-d3/dftd3.tgz";
    sha256 = "0n8gi0raz8rik1rkd4ifq43wxs56ykxlhm22hpyq3ak1ixszjz6r";
  };

  unpackPhase = ''
    tar -xvf $src
  '';

  # Using gfortran for linking instead of ifort
  patches = [
    ./Linking.patch
  ];

  dontConfigure = true;


  installPhase = ''
    mkdir -p $out/bin
    cp -p dftd3 $out/bin
  '';

  hardeningDisable = [
    "format"
  ];

  meta = with lib; {
    description = "Dispersion correction for DFT";
    homepage = "https://www.chemie.uni-bonn.de/pctc/mulliken-center/software/dft-d3/get-the-current-version-of-dft-d3";
    platforms = platforms.unix;
    license = licenses.unfree;
  };
}
