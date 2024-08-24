{
  lib,
  mpv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  clapper,
  gdk-pixbuf,
  glib,
  gtk4,
  gsettings-desktop-schemas,
  libadwaita,
  openssl,
  gst_all_1,
  wrapGAppsHook4,
  makeDesktopItem,
}:
rustPlatform.buildRustPackage rec {
  pname = "tsukimi";
  version = "0.8.2";
  src = fetchFromGitHub {
    owner = "tsukinaha";
    repo = "tsukimi";
    rev = "v${version}";
    hash = "sha256-m6z1n0EQKlNe24l/3bUb+6iUoxnTVsJ6vqdUkyNEmmE=";
  };

  cargoHash = "sha256-fRWp1VM9qXDl0zCV7v3bP4NJBLURDYUIthPwED25PDY=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs =
    [
      clapper
      gdk-pixbuf
      glib
      gtk4
      gsettings-desktop-schemas
      libadwaita
      openssl
      mpv
    ]
    ++ (with gst_all_1; [
      gst-plugins-base
      gstreamer
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
    ]);

  desktopItems = [
    (makeDesktopItem {
      name = "Tsukimi";
      exec = "tsukimi";
      icon = "tsukimi";
      desktopName = "tsukimi";
      comment = meta.description;
      categories = [
        "AudioVideo"
      ];
    })
  ];

  doCheck = false;

  postInstall = ''
    install -Dm 644 -t "$out/share/pixmaps/" resources/ui/icons/tsukimi.png
    install -Dm 644 -t "$out/share/glib-2.0/schemas" moe.tsuna.tsukimi.gschema.xml
    glib-compile-schemas $out/share/glib-2.0/schemas/
    cp -r "i18n/locale" "$out/share/locale"
  '';

  meta = {
    description = "A Simple Third-party Emby client";
    homepage = "https://github.com/tsukinaha/tsukimi";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ zzzsy ];
    mainProgram = "tsukimi";
  };
}
