{
  lib,
  stdenv,
  fetchFromSourcehut,
  installShellFiles,
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
  version = "0-unstable-2024-05-13";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "3a3d17d15ac940917bfe92fd115d0d2ae3605205";
    hash = "sha256-OOva23VxTl2Q+9+SIecazKBcan8UrJd7SMKeA9nnhlQ=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
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
