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
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "f00b4r0";
    repo = "acarsdec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eo5Uj4X8OtGMDTfVgr0TGwSzgUW8QzO0VSFY2Ogzq/M=";
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
