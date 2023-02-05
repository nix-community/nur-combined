{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "2023-01-26";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "0f5c49489d68f751f80ebf37920402ce9cf2ed47";
    hash = "sha256-iv+wGqcJFZ/hYPHDbAgcLCQ4DBCeVJWwME5N+6ev/EU=";
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
