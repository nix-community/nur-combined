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
  version = "0-unstable-2024-02-08";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "5623dd9b49377166fdb19ba4329db787b89aa447";
    hash = "sha256-+w6ceMmiU2JzbQnaSk9XV8N6qhV+oftljZ6ynXOAfsE=";
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
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
