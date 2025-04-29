{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cairo,
  curl,
  expat,
  ffmpeg,
  geographiclib,
  libevent,
  openimageio,
  openssl,
}:

stdenv.mkDerivation {
  pname = "gpx2video";
  version = "0-unstable-2025-04-25";

  src = fetchFromGitHub {
    owner = "progweb";
    repo = "gpx2video";
    rev = "732a5cf994eb650341088e01246d3856244454ab";
    hash = "sha256-ooUaCrHgIxi43p7Tq2CsxWEfqZcPSl4Gvi8HUqZEDyk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cairo
    curl
    expat
    ffmpeg
    geographiclib
    libevent
    openimageio
    openssl
  ];

  meta = {
    description = "Creating video with telemetry overlay from GPX data";
    homepage = "https://github.com/progweb/gpx2video";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    mainProgram = "gpx2video";
    skip.ci = stdenv.isDarwin;
    broken = true;
  };
}
