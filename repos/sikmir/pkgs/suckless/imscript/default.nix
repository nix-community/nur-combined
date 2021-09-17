{ lib, stdenv, fetchFromSourcehut, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2021-09-10";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = pname;
    rev = "dfdcad10f2f6a2481b4ec9b6929b750e5ebf9cb8";
    hash = "sha256-Y1TqT8+Fbbc2zlEuyoFw1oVVbrtacLp3N/SpAdTYIv8=";
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
