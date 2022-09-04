{ lib, stdenv, fetchFromSourcehut, installShellFiles
, libpng, libjpeg, libtiff, libwebp, fftwFloat, libX11, gsl }:

stdenv.mkDerivation rec {
  pname = "imscript";
  version = "2022-07-27";

  src = fetchFromSourcehut {
    owner = "~coco";
    repo = "imscript";
    rev = "258369bbb75422a3938041c8b11626e2c6e60088";
    hash = "sha256-8iU4dEwKHWXACLUSAzGP7ykeWmZBdkydiwUg8ip1bBQ=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ libpng libjpeg libtiff libwebp fftwFloat libX11 gsl ];

  makeFlags = [ "DISABLE_HDF5=1" "full" ];

  enableParallelBuilding = true;

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
    installManPage doc/man/*
  '';

  meta = with lib; {
    description = "A collection of small and standalone utilities for image processing";
    inherit (src.meta) homepage;
    license = licenses.agpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
