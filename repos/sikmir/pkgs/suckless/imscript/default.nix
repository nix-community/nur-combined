{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-05-09";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "e20691ed86c9b9b9799b847805d2e19954c6aad8";
    hash = "sha256-aFJ2dtp5fMW+zc8lrnv7AR56Dylm93kbEQcfKfu+uBA=";
  };

  buildInputs = [ libpng libjpeg libtiff fftwFloat libX11 gsl ];

  postPatch = ''
    substituteInPlace .deps.mk \
      --replace "ftr/fill_bill" "misc/fill_bill"
  '';

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
