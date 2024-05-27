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
  version = "0-unstable-2024-05-21";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "4471616ad570350c8b046d683c613178d949284e";
    hash = "sha256-Dbtzaru63BXdi+1m0iKM0QGaunJB/52clgQOxVaJg60=";
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
