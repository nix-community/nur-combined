{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdal,
  proj,
  qt5,
}:

stdenv.mkDerivation {
  pname = "garminimg";
  version = "0-unstable-2024-11-26";

  src = fetchFromGitHub {
    owner = "kiozen";
    repo = "GarminImg";
    rev = "0df6d7f5eafaed26054a64a593707297e4f435df";
    hash = "sha256-QkW3dri3qWMY1iLBH9+woHZ8CB/wD+QcTFw7sEW1b1k=";
  };


  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    gdal
    proj
  ];

  hardeningDisable = [ "format" ];

  installPhase = ''
    install -Dm755 bin/* -t $out/bin
  '';

  meta = {
    description = "Encode/decode a Garmin IMG file";
    homepage = "https://github.com/kiozen/GarminImg";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
