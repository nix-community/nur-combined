{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
}:

# AirSnare is zizzania's macOS-maintained fork: same dry-makefile build, plus an
# Objective-C channel-setting shim for CoreWLAN. On Darwin its config.Makefile
# links -framework CoreWLAN/-framework Foundation, which the stdenv's SDK
# provides. Both setup prerequisites (the dry Makefile and uthash.h) are checked
# into build_support/, so the build is offline.
stdenv.mkDerivation (finalAttrs: {
  pname = "airsnare";
  version = "0-unstable-2026-07-28";

  src = fetchFromGitHub {
    owner = "rtulke";
    repo = "airsnare";
    rev = "6a118786e0417ed32ace674344f16383fe68797c";
    hash = "sha256-pCUhW9y3hNBSTOhuO4Bhj97lFzfcWUkGudi/elRgehI=";
  };

  buildInputs = [ libpcap ];

  # `config.Makefile` is the checked-in project configuration: its default goal
  # materialises the generic dry Makefile and external/uthash.h, after which the
  # release profile builds src/airsnare.
  buildPhase = ''
    runHook preBuild

    make -f config.Makefile all
    make release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 src/airsnare "$out/bin/airsnare"
    install -Dm644 airsnare.conf.example "$out/share/airsnare/airsnare.conf.example"

    runHook postInstall
  '';

  meta = {
    description = "WPA/WPA2 handshake capture tool for macOS";
    homepage = "https://github.com/rtulke/airsnare";
    license = lib.licenses.mit;
    mainProgram = "airsnare";
    platforms = lib.platforms.darwin;
  };
})
