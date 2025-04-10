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
  version = "0-unstable-2025-04-04";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "587be9603f971e9eb8544e7e0d398ad1c5363ca9";
    hash = "sha256-l4IbMeYsi9EAwVratOWtnMt8gaekPXI5OjDtCqkqecg=";
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
