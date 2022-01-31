{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2022-01-26";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "c55c0bbf6b048d397c23db84569dbdcbd3ccdaee";
    hash = "sha256-lX6ongR+cOkAAeRvj/Q2NJNesibiuKOSwZcGjSERJHk=";
  };

  buildInputs = [ libpng libjpeg libtiff libwebp fftwFloat libX11 gsl ];

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
