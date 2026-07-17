{
  lib,
  stdenv,
  rustPlatform,
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pnpm,
  pkg-config,
  wrapGAppsHook4,
  cargo-tauri,
  glib-networking,
  gtk3,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
  gst_all_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cc-switch";
  version = "3.17.0";

  src = fetchFromGitHub {
    owner = "farion1231";
    repo = "cc-switch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pibPthEGtNw06wBu9ZIFdtqlTafTmiyFAawaH+Ou2gc=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-4S00JM93MR5ARL2eginyNh/0dIrzU5rJQYS1x1PYoig=";
  };

  cargoRoot = "src-tauri";
  cargoHash = "sha256-KCKhosPR2C5ShZ1ozFvlFF8bTmOrlbKzbgDX1hmhr2o=";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
  '';

  tauriBuildFlags = [ "--ignore-version-mismatches" ];
  # https://github.com/farion1231/cc-switch/pull/2316

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpmConfigHook
    pnpm
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    gtk3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}"
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "All-in-One assistant tool for Claude Code, Codex, OpenCode, openclaw and Gemini CLI";
    longDescription = ''
      CC-Switch is a cross-platform desktop application that provides a unified
      interface for multiple AI coding assistants including Claude Code, Codex,
      OpenCode, openclaw and Gemini CLI.
    '';
    homepage = "https://github.com/farion1231/cc-switch";
    changelog = "https://github.com/farion1231/cc-switch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "cc-switch";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
