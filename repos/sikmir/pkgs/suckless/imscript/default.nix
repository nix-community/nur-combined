{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-06-23";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "06618f60cf9bb5ee1b7ffcf208891403bff2c617";
    hash = "sha256-IxV1Ahszdc556VXfuTXnMEUe64V6s79neTO6usSVkbc=";
  };

  buildInputs = [ libpng libjpeg libtiff fftwFloat libX11 gsl ];

  makeFlags = [ "DISABLE_HDF5=1" "full" ];

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    install -Dm644 doc/man/* -t $out/share/man/man1
  '';

  meta = with lib; {
    description = "A collection of small and standalone utilities for image processing";
    inherit (src.meta) homepage;
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
