{
  lib,
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  copyDesktopItems,
  glib-networking,
  libayatana-appindicator,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  fetchFromGitHub,
  jq,
  moreutils,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zju-learning-assistant";
  version = "0.3.12";
  src = fetchFromGitHub {
    owner = "PeiPei233";
    repo = "zju-learning-assistant";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z3W1IMZFEvl0aiQP5+f0Zwslkkpq+B5XuteIXGGaKfY=";
  };

  cargoHash = "sha256-qyLPQoPFCVdBM9reA6aJnAXh2bgXA/jVDuRkvRF8hPU=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-npm-deps-${finalAttrs.version}";
    inherit (finalAttrs) src;
    hash = "sha256-BP+gYwbMZrSi5WZxf2ToTDuJRiy3ZXS6m5BxUd14Dng=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook

    pkg-config
    wrapGAppsHook4
    copyDesktopItems

    jq
    moreutils
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    webkitgtk_4_1
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  # from https://github.com/NixOS/nixpkgs/blob/04e40bca2a68d7ca85f1c47f00598abb062a8b12/pkgs/by-name/ca/cargo-tauri/test-app.nix#L23-L26
  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    jq \
    '.bundle.createUpdaterArtifacts = false' \
    src-tauri/tauri.conf.json \
    | sponge src-tauri/tauri.conf.json
  '';

  meta = {
    homepage = "https://github.com/PeiPei233/zju-learning-assistant";
    changelog = "https://github.com/PeiPei233/zju-learning-assistant/releases/tag/${finalAttrs.src.tag}";
    description = "帮你快速下载所有课件😋";
    mainProgram = "zju-learning-assistant";
    maintainers = with lib.maintainers; [ hhr2020 ];
    license = lib.licenses.mit;
  };
})
