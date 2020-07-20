{ lib, rustPlatform, fetchFromGitLab
, gdk-pixbuf, glib, meson, ninja, pkg-config, wrapGAppsHook
, gsettings-desktop-schemas, gtk3, libhandy, librsvg, openssl, sqlite
, webkitgtk
}:

rustPlatform.buildRustPackage {
  pname = "newsflash";
  version = "1.0.2";

  src = fetchFromGitLab {
    owner = "news-flash";
    repo = "news_flash_gtk";
    rev = "3d3d24f6e57097cb99073c084178c35fc268f8f4";
    sha256 = "00k11j7xq1lzfljwigmlygmzn5vys5rrggfc9r3hfnsfd425x129";
  };

  cargoPatches = [
    ./cargo.lock.patch
  ];

  cargoSha256 = "1x1l0267s012i8lc14652w7fcl8p92jvw9jbdj71k9pdy40jwwhy";

  patches = [
    ./no-post-install.patch
  ];

  postPatch = ''
    chmod +x build-aux/cargo.sh
    patchShebangs .
  '';

  nativeBuildInputs = [
    gdk-pixbuf # provides setup hook to fix "Unrecognized image file format"
    glib # provides glib-compile-resources to compile gresources
    meson
    ninja
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gsettings-desktop-schemas # used to get system default font in src/article_view/mod.rs
    gtk3
    libhandy
    librsvg # used by gdk-pixbuf & wrapGAppsHook setup hooks to fix "Unrecognized image file format"
    openssl
    sqlite
    webkitgtk
  ];

  # Unset default rust phases to use meson & ninja instead
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;
  installCheckPhase = null;

  meta = with lib; {
    description = "Modern feed reader";
    homepage = "https://gitlab.com/news-flash/news_flash_gtk";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
