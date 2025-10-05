{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  airspy,
  airspyhf,
  hackrf,
  libsamplerate,
  openssl,
  rtl-sdr,
  soxr,
  zeromq,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ais-catcher";
  version = "0.61";

  src = fetchFromGitHub {
    owner = "jvde-github";
    repo = "AIS-catcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xfv11X5Y4kcjsolSlOd4jvUCBryKylLYUUtlLKkcM5w=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    airspy
    airspyhf
    hackrf
    libsamplerate
    openssl
    rtl-sdr
    soxr
    zeromq
    zlib
  ];

  meta = {
    description = "A multi-platform AIS Receiver";
    homepage = "https://github.com/jvde-github/AIS-catcher";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "AIS-catcher";
  };
})
