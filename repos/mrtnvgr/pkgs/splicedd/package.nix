{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  cargo-tauri,
  rustPlatform,
  nodejs,
  yarnConfigHook,
  pkg-config,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "splicedd";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ascpixi";
    repo = "splicedd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RwerfUK94tuqpZXFWPID2ZELyo7GVue0nEptmg5ex4w=";
  };

  cargoHash = "sha256-UX+icbxVw/z58vX4y5fp5wAG7S+2XkARjCKwzecIl+Q=";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-Sms6NYXO3pGeJRXC1jo40sqGmHLyemADgkuaj+NlEjA=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    yarnConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  meta = {
    description = "Custom frontend for the Splice sample library";
    homepage = "https://github.com/ascpixi/splicedd";
    license = lib.licenses.gpl3Only;
    mainProgram = "splicedd";
    platforms = lib.platforms.linux;
  };
})
