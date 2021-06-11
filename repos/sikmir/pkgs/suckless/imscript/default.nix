{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-06-10";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "0fb0054ae8f8455a09d8c7f06740a2b24397d1c6";
    hash = "sha256-zQCSFBEp3Ye+FHRjXYphAxpsdbNKPaZCKHrFNQbGJoQ=";
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
