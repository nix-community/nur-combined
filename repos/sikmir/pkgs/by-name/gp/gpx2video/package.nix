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
  version = "0-unstable-2025-08-31";

  src = fetchFromGitHub {
    owner = "progweb";
    repo = "gpx2video";
    rev = "c5763300a9ad1008259f97273ad38c181149f2e2";
    hash = "sha256-qRN8oLJjfQJWDs6kLCqj3lD9ORN0owqFfZut3w40WTQ=";
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
    broken = true; # error: 'class OpenImageIO_v3_0::ImageBuf' has no member named 'errorf'
  };
}
