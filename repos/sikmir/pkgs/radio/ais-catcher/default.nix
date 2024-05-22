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
  version = "0.58";

  src = fetchFromGitHub {
    owner = "jvde-github";
    repo = "AIS-catcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7kN3EVyjlktnU7mhQa3emD8zqf9OSlzoh4xW8LLpvL8=";
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

  meta = with lib; {
    description = "A multi-platform AIS Receiver";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "AIS-catcher";
  };
})
