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
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    rev = "v${version}";
    hash = "sha256-0sB/u3Dv6G5VQMhFBoTJNxdwqFDLGgWCAAfrL5IgYIs=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-QkUl87XejDpujdTZhsStSRZqban0H5oxhgMZoLLvKEU=";

  pnpmDeps = pnpm_10.fetchDeps {
    inherit pname version src;
    sourceRoot = "${src.name}/apps/gpgui-helper";
    hash = "sha256-fBvVmux6fcDx1le9mpo6jCS9o8SpzPrufffu1YK31QM=";
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
    mainProgram = "gpgui-helper";
    platforms = lib.platforms.linux;
  };
}
