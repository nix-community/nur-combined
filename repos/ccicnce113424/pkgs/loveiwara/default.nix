{
  sources,
  version,
  srcInfo,
  lib,
  flutter341,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  sqlite,
  alsa-lib,
  mpv-unwrapped,
  libnotify,
  fetchpatch2,
}:
let
  flutter = flutter341;
in
flutter.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version;
  inherit (srcInfo) pubspecLock;
  inherit (srcInfo) gitHashes;

  customSourceBuilders.sqlite3_flutter_libs = { src, ... }: src;

  desktopItems = [
    (makeDesktopItem {
      name = "loveiwara";
      desktopName = "LoveIwara";
      genericName = "Love Iwara";
      exec = "i_iwara %u";
      comment = "Unofficial iwara application";
      terminal = false;
      categories = [
        "AudioVideo"
        "Video"
      ];
      keywords = [
        "Flutter"
        "share"
        "images"
      ];
      icon = "loveiwara";
      startupWMClass = "i_iwara";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    sqlite
    alsa-lib
    mpv-unwrapped
    libnotify
  ];

  patches = [
    (fetchpatch2 {
      name = "revert-transform-timeout.patch";
      url = "https://github.com/FoxSensei001/LoveIwara/commit/2634bc779de6a6de6ec6db10cceb28244d0cc8f9.patch?full_index=1";
      hash = "sha256-IeAVaSHdgErH//5ZPviObDrzjVogGoN9MF+vC9zm1tY=";
      revert = true;
    })
  ];

  postPatch = ''
    # https://github.com/NixOS/nixpkgs/blob/7905606cfa51a1815787377b9cb04291e87ebcb4/pkgs/by-name/fl/fluffychat/package.nix#L120
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail \
      "PRIVATE -Wall -Werror" \
      "PRIVATE -Wall -Werror -Wno-deprecated"

    # https://github.com/simolus3/sqlite3.dart/blob/f39d797adcb9ea9f7903982560d7076b596538f5/sqlite3/doc/hook.md#system-provided-sqlite
    cat <<EOL >> pubspec.yaml
    hooks:
      user_defines:
        sqlite3:
          source: system
    EOL
  '';

  postInstall = ''
    install -D assets/icon/launcher_icon_v2.png $out/share/icons/loveiwara.png
  '';

  meta = {
    description = "Unofficial Iwara app";
    homepage = "https://github.com/FoxSensei001/LoveIwara";
    mainProgram = "i_iwara";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
}
