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
  libX11,
  gsl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imscript";
  version = "0-unstable-2024-07-25";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "29ced5a5472f05b8e07cb621bf8693ee2916b354";
    hash = "sha256-YDDxzEiCqCaObFUsRpmMeRD0IqE3iTPbo90eYWvySkw=";
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
    libX11
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
