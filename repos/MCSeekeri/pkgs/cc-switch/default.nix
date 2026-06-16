{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pnpm_10,
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
  version = "3.16.3";

  src = fetchFromGitHub {
    owner = "farion1231";
    repo = "cc-switch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jj7FHJtXn127hqpjCe6buxvJNCtWxRe5HZPY8NRcglM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-Vs+/KLICqciF7dnC3iRH9TFzNCtXDgOkWFPLxdwA0rE=";
  };

  cargoRoot = "src-tauri";
  cargoHash = "sha256-PfTkrD3ts/OugZ5qM82tTfWwSOcSddgDYzQhr6wLvOg=";
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
    pnpm_10
    pnpmConfigHook
    wrapGAppsHook4
  ];

  buildInputs = [
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

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}"
    )
  '';

  meta = {
    description = "All-in-One assistant tool for Claude Code, Codex, OpenCode, openclaw and Gemini CLI";
    homepage = "https://github.com/farion1231/cc-switch";
    changelog = "https://github.com/farion1231/cc-switch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "cc-switch";
    platforms = lib.platforms.linux;
  };
})
