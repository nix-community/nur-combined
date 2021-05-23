{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-05-21";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "74270602e54c3d32ba93766d3a21fca0d846ea32";
    hash = "sha256-uY9Y8u46mZNtlIqIQWE2/g8skRTnk/cTBkwERiG7b/g=";
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
