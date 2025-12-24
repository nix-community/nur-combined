{
  lib,
  writeShellApplication,
  flutter,
  fetchFromGitHub,
  curl,
  jq,
  yq-go,
  nix,
  coreutils,
  gnused,
  gnugrep,
  perl,
  git,
  pkg-config,
  libsecret,
  jsoncpp,
  mpv,
  fetchzip,
  stdenv,
  libgbm,
  libdrm,
  libass,
  keybinder3,
  ffmpeg,
  makeDesktopItem,
  copyDesktopItems,
  imagemagick,
}:

let
  libwebrtc = fetchzip {
    url = "https://github.com/flutter-webrtc/flutter-webrtc/releases/download/v1.2.1/libwebrtc.zip";
    hash = "sha256-i4LRG44f//SDIOl072yZavkYoTZdiydPZndeOm6/fBM=";
  };
  libwebrtcRpath = lib.makeLibraryPath [
    libgbm
    libdrm
  ];
in
flutter.buildFlutterApplication rec {
  pname = "plezy";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "edde746";
    repo = "plezy";
    tag = version;
    hash = "sha256-I9jyWD5VKL52Vq6gXhNqccAM8x+eNShuzd3baygvHdA=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = {
    os_media_controls = "sha256-xfn4gzYTDe7sIsL4cqvX756+ZI9vR40Hr4FCyJXkGfs=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    libsecret
    jsoncpp
    mpv
    libass
    keybinder3
    ffmpeg
  ];

  env.NIX_LDFLAGS = "-rpath-link ${libwebrtcRpath}";

  desktopItems = [
    (makeDesktopItem {
      name = "plezy";
      exec = "plezy";
      icon = "plezy";
      desktopName = "Plezy";
      comment = "Modern cross-platform Plex client built with Flutter";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
      ];
    })
  ];

  customSourceBuilders = {
    flutter_webrtc =
      { version, src, ... }:
      stdenv.mkDerivation {
        pname = "flutter_webrtc";
        inherit version src;
        inherit (src) passthru;

        postPatch = ''
          substituteInPlace third_party/CMakeLists.txt \
            --replace-fail "\''${CMAKE_CURRENT_LIST_DIR}/downloads/libwebrtc.zip" ${libwebrtc}
          ln -s ${libwebrtc} third_party/libwebrtc
        '';

        installPhase = ''
          runHook preInstall

          mkdir $out
          cp -r ./* $out/

          runHook postInstall
        '';
      };
  };

  postInstall = ''
    patchelf --add-rpath ${libwebrtcRpath} $out/app/plezy/lib/libwebrtc.so

    install -Dm644 assets/plezy.png $out/share/icons/hicolor/128x128/apps/plezy.png
    for size in 16 24 32 48 64 256 512; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      convert assets/plezy.png -resize ''${size}x''${size} $out/share/icons/hicolor/''${size}x''${size}/apps/plezy.png
    done
  '';

  meta = {
    description = "Modern cross-platform Plex client built with Flutter";
    homepage = "https://github.com/edde746/plezy";
    mainProgram = "plezy";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

  passthru.updateScript = writeShellApplication {
    name = "update-plezy";
    runtimeInputs = [
      curl
      jq
      yq-go
      nix
      coreutils
      gnused
      gnugrep
      perl
      git
    ];
    text = builtins.readFile ./update.sh;
  };
}
