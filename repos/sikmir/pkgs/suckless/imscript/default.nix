{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2022-10-17";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "956cb6c5ec18eaa833280f16bc820b92be378078";
    hash = "sha256-1Gwog7cCVj6wve/Hd95AcpvNkUe4jnC9XRL1gkzxMZ8=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ libpng libjpeg libtiff libwebp fftwFloat libX11 gsl ];

  makeFlags = [ "DISABLE_HDF5=1" "full" ];

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    installManPage doc/man/*
  '';

  meta = with lib; {
    description = "A collection of small and standalone utilities for image processing";
    inherit (src.meta) homepage;
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
