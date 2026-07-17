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
  glm,
  gtkmm4,
  libepoxy,
  libevent,
  libpulseaudio,
  librsvg,
  openimageio,
  openssl,
  pango,
}:

stdenv.mkDerivation {
  pname = "gpx2video";
  version = "0-unstable-2026-07-15";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "progweb";
    repo = "gpx2video";
    rev = "4b3c96c0f33eeb888d183d838b1429d3568219e3";
    hash = "sha256-I9bfkLRwJ/9zjoWnfNIh2KZ+G9aPdzrbQZiGF1UH1O0=";
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
    glm
    gtkmm4
    libepoxy
    libevent
    libpulseaudio
    librsvg
    openimageio
    openssl
    pango
  ];

  meta = {
    description = "Creating video with telemetry overlay from GPX data";
    homepage = "https://github.com/progweb/gpx2video";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    mainProgram = "gpx2video";
    skip.ci = stdenv.isDarwin;
    broken = true; # error: no matching function for call to 'channels(OpenImageIO::v3_1::ImageBuf&, OpenImageIO::v3_1::ImageBuf&, int, int [4], float [0], std::string [4])'
  };
}
