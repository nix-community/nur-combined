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
  version = "0-unstable-2024-04-30";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "15d60d8b6cc6ccf4ea3da8fb585a217449d368cc";
    hash = "sha256-FZrIozaspU6gDXrhAFs5mU0jJEe94g9EfQ6ShKBDfRE=";
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
