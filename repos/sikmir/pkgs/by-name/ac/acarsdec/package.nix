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
  version = "4.6";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "f00b4r0";
    repo = "acarsdec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ehjT+ZBe5Jtpri7cNALXmWtfKhhtX0G2Hbbucm/C8jE=";
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
