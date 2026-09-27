{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  cargo-tauri,
  rustPlatform,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  pkg-config,
  glib-networking,
  libayatana-appindicator,
  openssl,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "splicerr";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "Robert-K";
    repo = "splicerr";
    tag = "app-v${finalAttrs.version}";
    hash = "sha256-hLKJ7tPk8N8WvZptj+lGt2OqH0MQo2+DQGYRTIfXv+Q=";
  };

  cargoHash = "sha256-TyxrjJmSjezeWLXSPlb6FD7CXFdjUt8ZYreTrEEcd7w=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-cJ24DlzeMN0mUeEzwgNFRZ/kpG3v95V1r6VCOMaRs/8=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail libayatana-appindicator3.so.1 '${libayatana-appindicator}/lib/libayatana-appindicator3.so.1'
  '';

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    openssl
    webkitgtk_4_1
  ];

  meta = {
    description = "Custom frontend for the Splice sample library";
    homepage = "https://github.com/Robert-K/splicerr";
    license = lib.licenses.mit;
    mainProgram = "splicerr";
    platforms = lib.platforms.linux;
  };
})
