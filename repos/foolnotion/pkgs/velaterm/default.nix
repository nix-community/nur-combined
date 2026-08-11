{
  cargo-tauri,
  fetchFromGitHub,
  fetchPnpmDeps,
  glib-networking,
  lib,
  libsoup_3,
  nodejs,
  openssl,
  pkg-config,
  pnpm_11,
  pnpmConfigHook,
  rustPlatform,
  stdenv,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "velaterm";
  version = "0.1.100";

  src = fetchFromGitHub {
    owner = "vlinx-io";
    repo = "VelaTerm";
    rev = "7735086fa263f3379b5982867b766410f781b656";
    hash = "sha256-encLYPtoWPgheXjk/afGnDlBLeK8503dlSEx7CRDsyc=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${finalAttrs.src}/src-tauri/Cargo.lock";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-fWhnef/5E5qU0ET8P5pZ97vtWut1RsE+qW9CPm//dnc=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpm_11
    pnpmConfigHook
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"beforeBuildCommand": "pnpm build"' '"beforeBuildCommand": "true"'
  '';

  preBuild = ''
    pnpm build
  '';

  postInstall = ''
    install -Dm644 src-tauri/icons/128x128.png \
      "$out/share/icons/hicolor/128x128/apps/velaterm.png"
  '';

  meta = {
    description = "Terminal manager for AI agent sessions";
    homepage = "https://github.com/vlinx-io/VelaTerm";
    license = lib.licenses.mit;
    mainProgram = "velaterm";
    platforms = lib.platforms.linux;
  };
})
