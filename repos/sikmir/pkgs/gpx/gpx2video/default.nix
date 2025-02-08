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
  version = "0-unstable-2015-02-07";

  src = fetchFromGitHub {
    owner = "progweb";
    repo = "gpx2video";
    rev = "399e25b75538d33ca355c0d60d8cb240e7dbda9f";
    hash = "sha256-rF3BbFe9nuUTBTGkHtQBqwkjYHrMycvCpt3D3K8bCAQ=";
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
  };
}
