{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "2023-05-13";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "643ec06c17bd04ef338323c2d1f08588c9e3cf70";
    hash = "sha256-TXQd+FjhvBjjA3rgGxkTgtEk2g7841iqYRycZmpC4lY=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ libpng libjpeg libtiff libwebp fftwFloat libX11 gsl ];

  makeFlags = [ "DISABLE_HDF5=1" "full" ];

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    installManPage doc/man/man1/*
  '';

  meta = with lib; {
    description = "A collection of small and standalone utilities for image processing";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
