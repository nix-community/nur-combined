{
  lib,
  flutter,
  rustPlatform,
  pkg-config,
  sysprof,
  gtk3,
  glib,
}:

let
  hub = rustPlatform.buildRustPackage {
    pname = "nrs-client-hub";
    version = "1.0.0";
    src = ./src/native/hub;
    cargoLock.lockFile = ./src/native/hub/Cargo.lock;
  };
in
flutter.buildFlutterApplication {
  pname = "nrs-client";
  version = "1.0.0";
  src = ./src;
  pubspecLock = lib.importJSON ./src/pubspec.lock.json;
  gitHashes = { };

  nativeBuildInputs = [
    pkg-config
    sysprof
  ];
  buildInputs = [
    gtk3
    glib
  ];

  preBuild = ''
    export PREBUILT_HUB_LIB="${hub}/lib/libhub.so"
  '';

  extraWrapProgramArgs = "--prefix LD_LIBRARY_PATH : $out/app/nrs-client/lib";

  meta = {
    description = "Client for the Australian National Relay Service (NRS) Internet Relay built with Flutter and Rinf";
    homepage = "https://nrschat.nrscall.gov.au/nrs/internetrelay";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nrs_client";
  };
}
