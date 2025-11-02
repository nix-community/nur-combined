{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cjson,
  libacars,
  libsndfile,
  paho-mqtt-c,
  rtl-sdr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "acarsdec";
  version = "4.3.1-unstable-2025-11-02";

  src = fetchFromGitHub {
    owner = "f00b4r0";
    repo = "acarsdec";
    rev = "4360dee11600bd6821883c1755fb156328976830";
    hash = "sha256-jb8YCtOVCkKwtzm6y/wQjYlkekD+ZUGkPb2T3DgoSW8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cjson
    libacars
    libsndfile
    paho-mqtt-c
    rtl-sdr
  ];

  meta = {
    description = "ACARS SDR decoder";
    homepage = "https://github.com/f00b4r0/acarsdec";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
