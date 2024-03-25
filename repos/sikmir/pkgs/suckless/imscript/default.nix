{ lib
, stdenv
, fetchFromSourcehut
, installShellFiles
, libpng
, libjpeg
, libtiff
, libwebp
, fftwFloat
, libX11
, gsl
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "0-unstable-2024-03-18";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "a98d2ccbbba678ace9b35d6fe13bca772f1c0e60";
    hash = "sha256-+jaerzq9RnYry98xoVY6QSSQZH+rwVcn0mLwymw3ieM=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ libpng libjpeg libtiff libwebp fftwFloat libX11 gsl ];

  makeFlags = [ "DISABLE_HDF5=1" "full" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    installManPage doc/man/man1/*
  '';

  meta = with lib; {
    description = "A collection of small and standalone utilities for image processing";
    homepage = "http://gabarro.org/ccn/itut/i.html";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
