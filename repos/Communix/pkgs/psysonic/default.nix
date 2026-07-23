{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  cmake,
  wrapGAppsHook3,
  pkg-config,
  openssl,
  glib-networking,
  webkitgtk_4_1,
  libayatana-appindicator,
  makeDesktopItem,
  gst_all_1,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  alsa-lib,
  atk,
  cairo,
  libsoup_3,
  glib,
  gdk-pixbuf,
  librsvg,
  pango,
}:
let
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ];
  gstPluginPath = lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "psysonic";
  version = "1.50.0";

  src = fetchFromGitHub {
    owner = "Psychotoxical";
    repo = "psysonic";
    tag = "app-v${finalAttrs.version}";
    hash = "sha256-KaG4eqM3HS3kwvQLS1FarCjnJ1GETosyNnb1VAneP9w=";
  };
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-ORdnzlm65b2HeaUrvZehq0jGDxbdchpCzRDPD0EFVh4=";
  };
  cargoRoot = "src-tauri";
  preBuild = ''
    cd src-tauri
  '';
  cargoHash = "sha256-krKZKPxVQOozV32O8G+rzCK/Pcfa4pg6hWyQIDkxfNU=";

  desktopItems = [
    (makeDesktopItem {
      name = "psysonic";
      desktopName = "Psysonic";
      comment = "Subsonic-compatible music player";
      icon = "psysonic";
      exec = "psysonic";
      categories = [
        "AudioVideo"
        "Audio"
        "Player"
      ];
    })
  ];

  postFixup = ''
    wrapProgram $out/bin/psysonic \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}" \
      --prefix GST_PLUGIN_PATH : "${gstPluginPath}" \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
  '';

  nativeBuildInputs = [
    cargo-tauri.hook

    nodejs
    npmHooks.npmConfigHook

    cmake
    pkg-config
    wrapGAppsHook3

  ];

  buildInputs = [
    glib-networking
    openssl
    libayatana-appindicator
    webkitgtk_4_1
    libsoup_3
    alsa-lib
    atk
    cairo
    gdk-pixbuf
    glib
    pango
    librsvg
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  meta = {
    description = "Desktop music player for Subsonic-compatible servers";
    homepage = "https://github.com/Psychotoxical/psysonic";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "psysonic";
  };
})
