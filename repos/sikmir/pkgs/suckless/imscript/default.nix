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
  version = "0-unstable-2025-09-19";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "3ef0973bb1dfc58452f4b896141d958729ca1693";
    hash = "sha256-Y4hekufXsTLBs/EcYuBDqgpAS0P0yoDU8Oiz4N+vXFQ=";
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
