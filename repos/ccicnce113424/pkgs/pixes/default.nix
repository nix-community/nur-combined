{
  sources,
  version,
  srcInfo,
  lib,
  flutter332,
  flutter335,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  flutter = if version == "1.2.0" then flutter332 else flutter335;
in
flutter.buildFlutterApplication {
  inherit (sources) pname src;
  inherit version;
  inherit (srcInfo) pubspecLock;
  inherit (srcInfo) gitHashes;

  desktopItems = [
    (makeDesktopItem {
      name = "pixes";
      desktopName = "Pixes";
      genericName = "Pixes";
      exec = "pixes %u";
      comment = "Unofficial pixiv application";
      terminal = false;
      categories = [ "Utility" ];
      keywords = [
        "Flutter"
        "share"
        "images"
      ];
      mimeTypes = [ "x-scheme-handler/pixiv" ];
      extraConfig.X-KDE-Protocols = "pixiv";
      icon = "pixes";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  postInstall = ''
    install -D debian/gui/pixes.png $out/share/pixmaps/pixes.png
  '';

  meta = {
    description = "Unofficial pixiv app";
    homepage = "https://github.com/wgh136/pixes";
    mainProgram = "pixes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.unix;
  };
}
