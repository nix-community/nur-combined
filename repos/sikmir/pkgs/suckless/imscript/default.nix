{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2022-06-09";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "2d9fb483df60a15ca128a9f19a1b679ea48dfa2b";
    hash = "sha256-hS2OqTCojfxyvdmfGKeR5LiFgPOUN7zEcadFOyn3pNo=";
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
