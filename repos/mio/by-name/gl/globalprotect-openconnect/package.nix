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
  gnutls,
  nix-update-script,
  writeShellApplication,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "globalprotect-openconnect";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ObMhGHNhND31kdqzpQpRmNN+zA1x/OR7I5eAFoIFNTA=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-R8/dH3q97iP6z+sLnBksyTY9RxXxCVTbDzkMYtDDUaQ=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    sourceRoot = "${finalAttrs.src.name}/apps/gpgui-helper";
    pnpm = pnpm_10;
    hash = "sha256-y+dB+opvyh5YQz5gzR+dwws/RTipu6pY6oS7P9AK0xc=";
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
    gnutls
  ];

  passthru.updateScript = writeShellApplication {
    name = "update-globalprotect-openconnect";
    text = ''
      export UPDATE_NIX_ATTR_PATH="globalprotect-openconnect"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    description = "A GlobalProtect VPN client (GUI) for Linux, based on OpenConnect";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    changelog = "https://github.com/yuezk/GlobalProtect-openconnect/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "gpgui-helper";
    platforms = lib.platforms.linux;
  };
})
