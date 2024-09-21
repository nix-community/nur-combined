{
  lib,
  mpv-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  ffmpeg,
  libadwaita,
  libepoxy,
  openssl,
  gst_all_1,
  wrapGAppsHook4,
  makeDesktopItem,
  copyDesktopItems
}:
rustPlatform.buildRustPackage rec {
  pname = "tsukimi";
  version = "0.12.2";
  src = fetchFromGitHub {
    owner = "tsukinaha";
    repo = "tsukimi";
    rev = "v${version}";
    hash = "sha256-pJ+SUNGQS/kqBdOg21GgDeZThcjnB0FhgG00qLfqxYA=";
  };

  cargoHash = "sha256-PCJiSyfEgK8inzoRmRvnAU50kLnyVhNrgLrwtBUFpIU=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    copyDesktopItems
  ];
  buildInputs =
    [
      ffmpeg
      libepoxy
      libadwaita
      openssl
      mpv-unwrapped
    ]
    ++ (with gst_all_1; [
      gst-plugins-base
      gstreamer
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
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

  postPatch = ''
    substituteInPlace build.rs \
      --replace-fail 'i18n/locale' "$out/share/locale"
    substituteInPlace src/main.rs \
      --replace-fail '/usr/share/locale' "$out/share/locale"
  '';

  postInstall = ''
    install -Dm 644 -t "$out/share/pixmaps/" resources/ui/icons/tsukimi.png
    install -Dm 644 -t "$out/share/glib-2.0/schemas" moe.tsuna.tsukimi.gschema.xml
    glib-compile-schemas $out/share/glib-2.0/schemas/
  '';

  meta = {
    description = "A Simple Third-party Emby client";
    homepage = "https://github.com/tsukinaha/tsukimi";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ zzzsy ];
    mainProgram = "tsukimi";
  };
}
