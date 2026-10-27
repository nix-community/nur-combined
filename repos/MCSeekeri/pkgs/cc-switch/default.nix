{
  lib,
  stdenv,
  rustPlatform,
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pnpm_12,
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
  version = "4.0.20";

  src = fetchFromGitHub {
    owner = "farion1231";
    repo = "cc-switch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tHamU9GQxfo+2QvczRFV8qO5ZrQzxiFX3yd3+JKXDQg=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    hash = "sha256-SzNQsn8QtvTjzx1b3R0xxA/46xztlkBUClpj5uGUfiE=";
  };

  cargoRoot = "src-tauri";
  cargoHash = "sha256-ZHndpX18+khp18/KyFSwKGn3uioFOIyAfagjeXC+T30=";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  checkFlags = [
    "--skip=unix_launcher_script_passes_env_past_rc_files_and_cleans_up"
    "--skip=npm_anchor_supplies_sibling_node_to_env_shebang"
    "--skip=probe_version_command_captures_healthy_tool_output"
    "--skip=mcode_history_uses_visible_roots_and_display_messages"
    "--skip=claude_updater_child_inherits_scoped_settings_without_parent_leakage"
    "--skip=test_parent_rollout_is_cached_once_across_fork_cutoffs"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=replacement_closes_the_previous_keep_alive_connection"
  ];

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
  '';

  env.NODE_ENV = "production";

  tauriBuildFlags = [ "--ignore-version-mismatches" ];
  # https://github.com/farion1231/cc-switch/pull/2316

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpmConfigHook
    pnpm_12
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
