{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  rustPlatform,
  rustc,
  cargo,
  wrapGAppsHook4,
  pkg-config,
  blueprint-compiler,
  desktop-file-utils,
  kdePackages,
  libxml2,
  zip,
  dbus,
  gtk4,
  libnfc,
  openssl,
  pcsclite,
  udev,
  python3,
  nixosTests,
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps."dbus-next"
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "credentialsd";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "linux-credentials";
    repo = "credentialsd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7rXO0ZYCf84BE9ZBx4zYwgrd4xR1gv0vtRuxTqvBMQ4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-ugb671Wxlx6T12sX+j/Wj9+mOO3mbfFebN5AGKmb7gI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    rustc
    cargo
    wrapGAppsHook4
    pkg-config
    blueprint-compiler
    desktop-file-utils
    kdePackages.appstream-qt
    libxml2
    zip
  ];

  buildInputs = [
    dbus
    gtk4
    libnfc
    openssl
    pcsclite
    udev
  ];

  dontWrapGApps = true;

  postFixup = ''
    substituteInPlace $out/bin/credentialsd-firefox-helper \
      --replace-fail '#!/usr/bin/env python3' '#!${pythonEnv.interpreter}'

    wrapGApp $out/bin/credentialsd
    wrapGApp $out/bin/credentialsd-ui
  '';

  passthru.tests.nixos = nixosTests.credentialsd;

  meta = {
    description = "Linux Credential Manager API";
    homepage = "https://github.com/linux-credentials/credentialsd";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
