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
  version = "2023-09-08";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "2cdd4b19cbe9073afbedd98be52241c588087a5a";
    hash = "sha256-jYc3V5nFeX9zjGSO7nalRcTiHaBEPFOMXHTtf/iOmNw=";
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
    homepage = "http://gabarro.org/ccn/itut/i.html";
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
