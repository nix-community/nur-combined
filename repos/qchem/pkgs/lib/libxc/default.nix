{ lib, stdenv, fetchurl, gfortran, perl } :

let
  version = "4.3.4";

in stdenv.mkDerivation {
  pname = "libxc";
  inherit version;

  src = fetchurl {
    url = "http://www.tddft.org/programs/octopus/down.php?file=libxc/${version}/libxc-${version}.tar.gz";
    sha256 = "0dw356dfwn2bwjdfwwi4h0kimm69aql2f4yk9f2kk4q7qpfkgvm8";
  };

  nativeBuildInputs = [ perl gfortran ];

  preConfigure = ''
    patchShebangs ./
  '';

  # fix a bug in the header file, which causes bagel to fail
  postFixup = ''
    sed -i '/#include "config.h"/d' $out/include/xc.h
  '';

  configureFlags = [ "--enable-shared" ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Library of exchange-correlation functionals for density-functional theory";
    homepage = "https://octopus-code.org/wiki/Libxc";
    license = licenses.lgpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ markuskowa ];
  };
}
