{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri_1,
  nodejs,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  pkg-config,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  wrapGAppsHook4,
  libayatana-appindicator,
  yq-go,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "forku-chatgpt";
  version = "1.1.0-unstable-20250430";

  src = fetchFromGitHub {
    owner = "canstralian";
    repo = "ForkU-ChatGPT";
    rev = "c828fa01c04c885f75780e89a0a10082979b10b5";
    hash = "sha256-Lugwv/p1AJ74cQNc8t5qR6imRcn68/DiFuyWoB9n8MA=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 1;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [
    cargo-tauri_1.hook
    nodejs
    pnpmConfigHook
    pnpm_9
    pkg-config
    wrapGAppsHook4
    yq-go
  ];

  buildInputs = [
    glib-networking
    libayatana-appindicator
    openssl
    webkitgtk_4_1
  ];

  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    substituteInPlace package.json \
      --replace-fail '"version": "0.0.0"' '"version": "${finalAttrs.version}"'

    substituteInPlace src-tauri/Cargo.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'

    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"beforeDevCommand": "npm run dev:fe"' '"beforeDevCommand": "pnpm run dev:fe"' \
      --replace-fail '"beforeBuildCommand": "npm run build:fe"' '"beforeBuildCommand": "pnpm run build:fe"' \
      --replace-fail '"version": "1.1.0"' '"version": "${finalAttrs.version}"'

    yq -iPo=json '
      .tauri.updater.active = false |
      .tauri.updater.endpoints = []
    ' src-tauri/tauri.conf.json
  '';

  doCheck = false;

  meta = {
    description = "ChatGPT desktop application (ForkU fork)";
    homepage = "https://github.com/canstralian/ForkU-ChatGPT";
    license = lib.licenses.agpl3Only;
    mainProgram = "ChatGPT";
    platforms = lib.platforms.linux;
  };
})
