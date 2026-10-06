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
  pname = "ai-toolbox";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "coulsontl";
    repo = "ai-toolbox";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EMnRAluOyR9OeYpFcfNqa6c6WWQ6Z+15cgypz2uNRtE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    hash = "sha256-kRASqFDJuJDtC2/D6MELaO48hZFf4C9zKumo3WIbqZ0=";
  };

  doCheck = false;

  cargoRoot = "tauri";
  cargoHash = "sha256-F9kwfOMDtDpdBukfbWexRwU6HbiU89R/fl+od41rpQ8=";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  postPatch = ''
    substituteInPlace tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
  '';

  env.NODE_ENV = "production";

  tauriBuildFlags = [ "--ignore-version-mismatches" ];

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
