{
  lib,
  stdenv,
  fetchFromGitLab,
  rustPlatform,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  meson,
  ninja,
  pkg-config,
  rustc,
  wrapGAppsHook4,
  gdk-pixbuf,
  clapper-unwrapped,
  gtk4,
  libadwaita,
  libxml2,
  openssl,
  sqlite,
  webkitgtk_6_0,
  glib-networking,
  librsvg,
  gst_all_1,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "newsflash";
  version = "4.1.2";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-yNO9ju5AQzMeZlQN1f3FRiFA6hq89mSuQClrJkoM+xE=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-gF1wHLM5t0jYm/nWQQeAbDlExsPYNV0/YYH0yfQuetM=";
  };

  postPatch = ''
    patchShebangs build-aux/cargo.sh
    meson rewrite kwargs set project / version '${finalAttrs.version}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    blueprint-compiler
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustc
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    wrapGAppsHook4

    # Provides setup hook to fix "Unrecognized image file format"
    gdk-pixbuf

  ];

  buildInputs = [
    clapper-unwrapped
    gtk4
    libadwaita
    libxml2
    openssl
    sqlite
    webkitgtk_6_0

    # TLS support for loading external content in webkitgtk WebView
    glib-networking

    # SVG support for gdk-pixbuf
    librsvg
  ]
  ++ (with gst_all_1; [
    # Audio & video support for webkitgtk WebView
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  passthru.updateScript = gitUpdater {
    rev-prefix = "v.";
    ignoredVersions = "(alpha|beta|rc)";
  };

  meta = {
    description = "Modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      kira-bruneau
      stunkymonkey
    ];
    teams = [ lib.teams.gnome-circle ];
    platforms = lib.platforms.unix;
    mainProgram = "io.gitlab.news_flash.NewsFlash";
    broken = stdenv.isDarwin; # webkitgtk doesn't build on Darwin
  };
})
