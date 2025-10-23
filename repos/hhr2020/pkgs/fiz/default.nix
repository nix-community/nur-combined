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

rustPlatform.buildRustPackage rec {
  pname = "fiz";
  version = "0.3.6";
  src = fetchFromGitHub {
    owner = "CrazySpottedDove";
    repo = "fiz";
    rev = "app-v${version}";
    hash = "sha256-08GpdpRCSSCwKsIe0rKwogxvF6mUuSG18yHR1w9cHi4=";
  };

  cargoHash = "sha256-1ERKMENPMTn5CPK4d5uTZ18ONMrCEY2PIK1GqSGHnSg=";

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
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
  buildAndTestSubdir = cargoRoot;

  postPatch = ''
    jq \
    '.bundle.createUpdaterArtifacts = false' \
    src-tauri/tauri.conf.json \
    | sponge src-tauri/tauri.conf.json
  '';

  meta = {
    homepage = "https://github.com/CrazySpottedDove/fiz";
    changelog = "https://github.com/CrazySpottedDove/fiz/releases/tag/app-v${version}";
    description = "高速简洁的学在浙大第三方";
    mainProgram = "fiz";
    license = lib.licenses.mit;
  };
}
