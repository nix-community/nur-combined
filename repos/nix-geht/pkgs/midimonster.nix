{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  darwin,
  alsa-lib ? null,
  libevdev ? null,
  IOKit ? null,
  lua5_3,
  olaSupport ? false,
  ola,
  libjack2,
  openssl,
  python3,
  ...
}:
stdenv.mkDerivation rec {
  pname = "midimonster";
  version = "0.6-unstable-2024-06-24";

  src = fetchFromGitHub {
    owner = "cbdevnet";
    repo = "midimonster";
    rev = "c247b034e6e06850af8e58a6ba4adf85c0a18071";
    hash = "sha256-RGs9J0CCeNj/RN0/D/MUdGK/tsdInE2P6IdlUuTpE1I";
  };

  nativeBuildInputs = [pkg-config];
  buildInputs =
    [lua5_3 libjack2 openssl python3]
    ++ lib.optionals stdenv.isLinux [alsa-lib libevdev]
    ++ lib.optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.IOKit]
    ++ lib.optionals olaSupport [ola];

  postBuild = lib.optionalString olaSupport ''
    cd backends
    make ola.so
  '';

  makeFlags = ["PREFIX=$(out)" "PLUGINS=$(out)/lib/midimonster"];
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Multi-protocol control & translation software (ArtNet, MIDI, OSC, sACN, ...)";
    homepage = "https://midimonster.net";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [vifino];
  };
}
