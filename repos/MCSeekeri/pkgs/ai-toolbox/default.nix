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
  pname = "ai-toolbox";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "coulsontl";
    repo = "ai-toolbox";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NoblzpcK0PHAC/LBpnE8TtS1OzKNsUsfW40HdTPhroM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-gu7inTXG64DTI3ywOrv/OyVFM3kmW0NqCzI8hQyRY4g=";
  };

  doCheck = false;

  cargoRoot = "tauri";
  cargoHash = "sha256-h1D3yEavTfskutN3ipN9k/nmAtII5/SMQMyGwdW7akw=";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  postPatch = ''
    substituteInPlace tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
  '';

  tauriBuildFlags = [ "--ignore-version-mismatches" ];

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
    description = "Personal AI Toolbox — manage AI coding assistant configurations in one place";
    longDescription = ''
      AI Toolbox is a cross-platform desktop app that helps developers manage
      configurations for various AI coding assistants. It supports OpenCode,
      Claude Code, Codex CLI, Oh-My-OpenCode, MCP servers, Skills, and more,
      with a visual interface, system tray quick-switching, WSL sync, and data
      backup/restore.
    '';
    homepage = "https://github.com/coulsontl/ai-toolbox";
    changelog = "https://github.com/coulsontl/ai-toolbox/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "ai-toolbox";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
