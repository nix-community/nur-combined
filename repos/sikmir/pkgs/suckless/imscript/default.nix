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
  version = "0-unstable-2024-07-09";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "712e8f48f1221b382c77eb3e49535e8ae22b5bc8";
    hash = "sha256-m8uRn3XZPliygEVmIq19n9xy2LnDlDgpkJr5n266y5Y=";
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
