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
  publicsuffix-list,
  udev,
  python3,
  nixosTests,
  nix-update-script,
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps.dbus-next
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "credentialsd";
  version = "0.4.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "linux-credentials";
    repo = "credentialsd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7IlHBJtRUObfPB/H8WJaSNcOJidB8JumTO1okIkYlus=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-hZzFXHUZ5D9geNyBZSvBUoIFhdfhSVzhtTFBayndGu8=";
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

    substituteInPlace "$cargoDepsCopy"/*/libwebauthn-*/src/ops/webauthn/psl/dat.rs \
      --replace-fail '/usr/share/publicsuffix/public_suffix_list.dat' \
        '${publicsuffix-list}/share/publicsuffix/public_suffix_list.dat'
  '';

  dontWrapGApps = true;

  postFixup = ''
    substituteInPlace $out/bin/credentialsd-firefox-helper \
      --replace-fail '#!/usr/bin/env python3' '#!${pythonEnv.interpreter}'

    wrapGApp $out/bin/credentialsd
    wrapGApp $out/bin/credentialsd-ui
  '';

  passthru.tests.nixos = nixosTests.credentialsd;

  passthru.updateScript = nix-update-script { };

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
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "credentialsd";
  };
})
