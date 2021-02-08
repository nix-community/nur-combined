{ lib
, rustPlatform
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapGAppsHook
, gdk-pixbuf
, glib
, gtk3
, libhandy
, openssl
, sqlite
, webkitgtk
, glib-networking
, librsvg
, gst_all_1
}:

rustPlatform.buildRustPackage rec {
  pname = "newsflash";
  version = "1.2.1";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = version;
    hash = "sha256:08d47crs777cangabpap4s9y6ykpk9cfbn7rwq0rxshhnfh90sz4";
  };

  cargoHash = "sha256:1qlqfazzrlkz3v09d1jlbbqikbk77an22gy8sr2iksnmakwzf4f4";

  patches = [
    ./no-post-install.patch
  ];

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook

    # Provides setup hook to fix "Unrecognized image file format"
    gdk-pixbuf

    # Provides glib-compile-resources to compile gresources
    glib
  ];

  buildInputs = [
    gtk3
    libhandy
    openssl
    sqlite
    webkitgtk

    # TLS support for loading external content in webkitgtk WebView
    glib-networking

    # SVG support for gdk-pixbuf
    librsvg
  ] ++ (with gst_all_1; [
    # Audio & video support for webkitgtk WebView
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  # Unset default rust phases to use meson & ninja instead
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;
  installCheckPhase = null;

  meta = with lib; {
    description = "A modern feed reader designed for the GNOME desktop";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
