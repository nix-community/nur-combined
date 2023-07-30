{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "2023-07-17";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "a45d5956ae714beff132eb170a36e707792755b0";
    hash = "sha256-9SN3Vc70lFdJuODfA+lDLRurOhxcX5UcVlpo0oPDSuo=";
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
