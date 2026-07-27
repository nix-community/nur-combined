{
  lib,
  stdenv,
  fetchFromGitHub,
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

rustPlatform.buildRustPackage rec {
  pname = "globalprotect-openconnect";
  version = "2.6.4-unstable-2026-07-28";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    rev = "66f48b3ff62b23dd6d53c3134232302a34dae82a";
    hash = "sha256-LjoYBZ7ACdU+SmmAaspNshHInrOTD4qSSriCmv7pDNM=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-9O9DHkn2ZG3SOnqjd5xYTNTTJ3w6yj0bs9Nl7m+rg64=";

  pnpmDeps = pnpm_10.fetchDeps {
    inherit pname version src;
    sourceRoot = "${src.name}/apps/gpgui-helper";
    hash = "sha256-zqsLkfst34fIcDAohqfwMt5yqfOXUUV51fuXoQE/ds0=";
    fetcherVersion = 4;
  };

  buildAndTestSubdir = "apps/gpgui-helper/src-tauri";
  pnpmRoot = "apps/gpgui-helper";

  nativeBuildInputs = [
    pkg-config
    cargo-tauri.hook
    nodejs
    pnpm_10.configHook
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
    license = lib.licenses.gpl3Only;
    mainProgram = "gpgui";
    platforms = lib.platforms.linux;
  };
}
