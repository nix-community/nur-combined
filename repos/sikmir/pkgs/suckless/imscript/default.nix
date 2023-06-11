{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "2023-06-01";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "3df6c7ccda23663ada152e6052d2b5aa2f17f7b6";
    hash = "sha256-TsTXbkJc6doUkayUqo3ptLm5KdfFyXQ/1LjccOLQXrU=";
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
