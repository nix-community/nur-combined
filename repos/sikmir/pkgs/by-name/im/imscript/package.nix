{
  lib,
  stdenv,
  fetchFromSourcehut,
  installShellFiles,
  hdf5,
  libheif,
  libpng,
  libjpeg,
  libtiff,
  libwebp,
  fftwFloat,
  libx11,
  gsl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "0-unstable-2026-08-03";

  __structuredAttrs = true;

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "998f6a3c7697994a3bf9995d3958df6bf7b88979";
    hash = "sha256-EZE9ZZkZ57ehtMWn+2AKYH90giSYimXHEfifPo5u5Uw=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    hdf5
    libheif
    libpng
    libjpeg
    libtiff
    libwebp
    fftwFloat
    libx11
    gsl
  ];

  makeFlags = [
    "DISABLE_HDF5=1"
    "full"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    installManPage doc/man/man1/*
  '';

  meta = {
    description = "A collection of small and standalone utilities for image processing";
    homepage = "http://gabarro.org/ccn/itut/i.html";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
