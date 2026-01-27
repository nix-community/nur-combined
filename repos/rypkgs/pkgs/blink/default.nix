{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook4,
  openssl,
  webkitgtk_4_1,
  glib-networking,
  libsoup_3,
  gst_all_1,
  makeDesktopItem,
  copyDesktopItems,
  jq,
  moreutils,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "blink";
  version = "1.0.0-alpha03";

  src = fetchFromGitHub {
    owner = "prayag17";
    repo = "Blink";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C2qMR9GgZBukITkSV+yKfys6Z1wANmcypYrpevSerFQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 1;
    hash = "sha256-s/FUu/QGImUVV7sx2KUoL+CQeM0HG9erj1Hvz6kRxwE=";
  };

  postPatch = ''
    # Disable updater artifacts to fix bundling
    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
  '';

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-bDhTsAaO/v8HiQBXuala5ZSjMIdrVr0rAE++/x4pM7Y=";

  nativeBuildInputs = [
    jq
    moreutils
    pnpmConfigHook
    pnpm_10
    nodejs
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook4
    copyDesktopItems
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    glib-networking
    libsoup_3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  postInstall = ''
    install -Dm644 src-tauri/icons/128x128.png $out/share/icons/hicolor/128x128/apps/blink.png
    install -Dm644 src-tauri/icons/32x32.png $out/share/icons/hicolor/32x32/apps/blink.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "blink";
      exec = "blink";
      icon = "blink";
      desktopName = "Blink";
      genericName = "Jellyfin Client";
      comment = "A Modern Jellyfin Client";
      categories = [ "AudioVideo" "Video" "Player" ];
      terminal = false;
    })
  ];

  meta = {
    description = "A Modern Jellyfin Client";
    longDescription = ''
      Blink is a modern, cross-platform desktop client for Jellyfin media servers.
      Features include DirectPlay support, multi-server management, and media
      info recognition for Dolby Vision, Atmos, DTS, HDR10+, and more.
    '';
    homepage = "https://github.com/prayag17/Blink";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "blink";
  };
})
