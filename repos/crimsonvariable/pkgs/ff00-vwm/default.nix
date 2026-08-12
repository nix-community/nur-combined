{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  gdk-pixbuf,
  gtk4,
  libx11,
  libxrandr,
  librsvg,
  mpv,
  webp-pixbuf-loader,
  gnome,
}:

let
  pixbufLoaderCache = gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
    extraLoaders = [
      librsvg
      webp-pixbuf-loader
    ];
  };
in
rustPlatform.buildRustPackage rec {
  pname = "ff00-vwm";
  version = "0.2.0-alpha.1";

  src = fetchFromGitHub {
    owner = "crimsonvariable";
    repo = "ff00-vwm";
    tag = "v${version}";
    hash = "sha256-9xBU9oohqTCJMuGT3l5IBI/R3EwE6Jd5M9RF8hGvSGg=";
  };

  cargoHash = "sha256-l07dnG3Yg0G7qcw2NnjGdUDUmlwbGFh3f5leCDMPNB8=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    gtk4
    libx11
    libxrandr
    librsvg
    webp-pixbuf-loader
  ];

  GDK_PIXBUF_MODULE_FILE = pixbufLoaderCache;

  postInstall = ''
    install -Dm644 data/com.crimsonvariable.FF00Vwm.desktop \
      "$out/share/applications/com.crimsonvariable.FF00Vwm.desktop"
    install -Dm644 data/icons/ff00-vwm.svg \
      "$out/share/icons/hicolor/scalable/apps/ff00-vwm.svg"
    install -Dm644 README.md CHANGELOG.md LICENSE THIRD_PARTY_NOTICES.md \
      THIRD_PARTY_LICENSES.txt TYPEFACE_CREDITS.md \
      -t "$out/share/doc/ff00-vwm"
  '';

  preFixup = ''
    export GDK_PIXBUF_MODULE_FILE=${pixbufLoaderCache}
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ mpv ]}
    )
  '';

  meta = {
    description = "Per-monitor video and image wallpaper manager for Linux X11";
    homepage = "https://crimsonvariable.com/projects/ff00-vwm/";
    changelog = "https://github.com/crimsonvariable/ff00-vwm/blob/v${version}/CHANGELOG.md";
    downloadPage = "https://github.com/crimsonvariable/ff00-vwm/releases";
    license = lib.licenses.agpl3Plus;
    mainProgram = "ff00-vwm";
    platforms = [ "x86_64-linux" ];
  };
}
