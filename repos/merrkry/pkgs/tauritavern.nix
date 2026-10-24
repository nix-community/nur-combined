{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchPnpmDeps,
  cargo-tauri,
  nodejs_22,
  pnpm_11,
  pnpmConfigHook,
  pkg-config,
  wrapGAppsHook4,
  dbus,
  glib-networking,
  gst_all_1,
  gtk3,
  libayatana-appindicator,
  librsvg,
  openssl,
  webkitgtk_4_1,
  cacert,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "tauritavern";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "Darkatse";
    repo = "TauriTavern";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uMeWo8bSkWKSTBdfh+L8q3q8cOQbLkSlz6OZlrxv0h4=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri/crates/tauritavern";
  cargoHash = "sha256-S64BAl4sRMfQE+SHLiCZV8muuR6PUzPa2pRvmuL57zc=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-OW+VubqLTHYrvrO/t604avoiv18qFWWHgIxCIY3/zjA=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs_22
    pnpm_11
    pnpmConfigHook
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs = [
    dbus
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    libayatana-appindicator
    librsvg
    openssl
    webkitgtk_4_1
  ];

  tauriBundleType = "deb";
  env.TAURITAVERN_BUILD_BRANCH = "main";

  doCheck = true;
  nativeCheckInputs = [
    cacert
    git
  ];
  checkType = "debug";
  checkNoDefaultFeatures = true;
  cargoTestFlags = [
    "--workspace"
    "--tests"
  ];
  preCheck = ''
    pnpm run test:browser
    pnpm run test:contracts
    pnpm run test:ui
  '';

  meta = {
    description = "SillyTavern rewritten in Tauri/Rust";
    homepage = "https://github.com/Darkatse/TauriTavern";
    changelog = "https://github.com/Darkatse/TauriTavern/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "tauritavern";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
