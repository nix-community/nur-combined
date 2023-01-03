{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "2022-12-15";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "3758dd3cbe4e3e4052112182e6ca645c1e41e008";
    hash = "sha256-fv/urp9AOu2BlksLA/TPbTuoaoF2yigVbcW7oyW+UBY=";
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
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
