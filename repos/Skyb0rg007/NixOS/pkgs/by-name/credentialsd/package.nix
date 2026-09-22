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
    ps.dbus-next
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "credentialsd";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "linux-credentials";
    repo = "credentialsd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wCkgO/T8UCQLMAY6HyxEL0HlGFlRhqGC+bZc6XhcTwU=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-+YEr2bPkJwl0DEWMjKDCjIgq5SX54T2jsbYRbRPGOwQ=";
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

  postPatch = ''
    substituteInPlace credentialsd-ui/data/resources/icons/copy-icons.py \
      --replace-fail '#!/usr/bin/python3' '#!${python3.interpreter}'
  '';

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
    longDescription = ''
      Proposal for a Linux credential management xdg portal D-Bus
      specification, including webauthn/passkey support
    '';
    homepage = "https://github.com/linux-credentials/credentialsd";
    changelog = "https://github.com/linux-credentials/credentialsd/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
  };
})
