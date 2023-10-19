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
  version = "2023-10-09";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "6f7f02bf6ff70c3446daec996d06dbcbe9cd8522";
    hash = "sha256-3Q01YH9bPEUMKEcuGTI60tvCDUuldPfe+QFtqjy21B8=";
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
