{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-07-19";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "ede7a82a15649c5a5573b0ffd2a6cb5894f2f1d8";
    hash = "sha256-uxCrmg1B9nsDOUvH3Yi6LwJ6KpwRCshjJHJ2seo0Ibc=";
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
