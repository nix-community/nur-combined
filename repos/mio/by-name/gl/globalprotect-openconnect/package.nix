{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  rustPlatform,
  pkg-config,
  cargo-tauri,
  nodejs,
  pnpm_10,
  wrapGAppsHook4,
  glib,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  libsecret,
  libayatana-appindicator,
  glib-networking,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "globalprotect-openconnect";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nQl+zXsO+8hxZ+RLPA+hxEX7FhM2GN22Qb1sTFxvPKk=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-CqcGbfsIMSnCYUwvgC+jXDINJr9zaLHgc8VsOmHT1go=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    sourceRoot = "${finalAttrs.src.name}/apps/gpgui-helper";
    pnpm = pnpm_10;
    hash = "sha256-fBvVmux6fcDx1le9mpo6jCS9o8SpzPrufffu1YK31QM=";
    fetcherVersion = 4;
  };

  buildAndTestSubdir = "apps/gpgui-helper/src-tauri";
  pnpmRoot = "apps/gpgui-helper";

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cargo-tauri.hook
    nodejs
    pnpmConfigHook
    pnpm_10
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    libsoup_3
    openssl
    libsecret
    libayatana-appindicator
    glib-networking
  ];

  meta = {
    description = "A GlobalProtect VPN client (GUI) for Linux, based on OpenConnect";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    changelog = "https://github.com/yuezk/GlobalProtect-openconnect/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpgui-helper";
    platforms = lib.platforms.linux;
  };
})
