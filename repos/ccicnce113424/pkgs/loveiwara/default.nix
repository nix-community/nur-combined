{
  sources,
  version,
  srcInfo,
  lib,
  flutter338,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
  mpv-unwrapped,
}:
let
  flutter = flutter338;
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
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    autoPatchelfHook
  ];

  # https://github.com/NixOS/nixpkgs/blob/7905606cfa51a1815787377b9cb04291e87ebcb4/pkgs/by-name/fl/fluffychat/package.nix#L120
  postPatch = ''
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail \
      "PRIVATE -Wall -Werror" \
      "PRIVATE -Wall -Werror -Wno-deprecated"
  '';

  postInstall = ''
    ln --symbolic --no-dereference --force ${mpv-unwrapped}/lib/libmpv.so.2 $out/app/loveiwara/lib/libmpv.so.2
    install -D assets/icon/launcher_icon_v2.png $out/share/pixmaps/loveiwara.png
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
