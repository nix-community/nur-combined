{
  lib,
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  copyDesktopItems,
  glib-networking,

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
  pname = "fiz";
  version = "0.3.9";
  src = fetchFromGitHub {
    owner = "CrazySpottedDove";
    repo = "fiz";
    tag = "app-v${finalAttrs.version}";
    hash = "sha256-fz2mx8EB45OZAT3KI0LjpXNFWWNsPOnOdbYHnNXjA74=";
  };

  cargoHash = "sha256-1ERKMENPMTn5CPK4d5uTZ18ONMrCEY2PIK1GqSGHnSg=";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-npm-deps-${finalAttrs.version}";
    inherit (finalAttrs) src;
    hash = "sha256-jSgBrMPDmC98bcG44s0npA0Gu0mG8/qbJ3X3wNIHSY8=";
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
    webkitgtk_4_1
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  postPatch = ''
    jq \
    '.bundle.createUpdaterArtifacts = false' \
    src-tauri/tauri.conf.json \
    | sponge src-tauri/tauri.conf.json
  '';

  meta = {
    homepage = "https://github.com/CrazySpottedDove/fiz";
    changelog = "https://github.com/CrazySpottedDove/fiz/releases/tag/${finalAttrs.src.tag}";
    description = "高速简洁的学在浙大第三方";
    mainProgram = "fiz";
    maintainers = with lib.maintainers; [ hhr2020 ];
    license = lib.licenses.mit;
  };
})
