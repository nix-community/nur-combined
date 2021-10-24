{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-10-20";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "3619d8e0d3b273d1f912a038e52a88c30c05c5a1";
    hash = "sha256-3S3I+ttsF4IAO095r1eodhOaCWxPU6N2h5KzPc9pev0=";
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
