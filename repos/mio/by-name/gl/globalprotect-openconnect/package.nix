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
  version = "2.6.4-unstable-2026-08-06";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    rev = "d75e422c1d10e77c5e7c5af2ddd2cca6114912c9";
    hash = "sha256-iCxMw4WxxHQ4q+TB6b4TLEoPD3A26xzVNEinvmWHofE=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-6+x5SRQHIchtkdYZAZl+b28hMCaiQHrp9i3tMsN3DhE=";

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
