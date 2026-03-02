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
  version = "0.66";

  src = fetchFromGitHub {
    owner = "jvde-github";
    repo = "AIS-catcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O+6b5AWlQjUJDFEunmsGNs3vV8h/4iCR9PxzwuSVfoM=";
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
