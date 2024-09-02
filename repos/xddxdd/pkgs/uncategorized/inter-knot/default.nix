{
  sources,
  lib,
  flutter,
  imagemagick,
  copyDesktopItems,
  makeDesktopItem,
  ...
}:
flutter.buildFlutterApplication {
  inherit (sources.inter-knot) pname version src;

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [
    imagemagick
    copyDesktopItems
  ];

  postInstall = ''
    mkdir -p $out/share/pixmaps
    convert \
      -depth 24 \
      -define png:compression-filter=1 \
      -define png:compression-level=9 \
      -define png:compression-strategy=2 \
      $src/assets/images/icon.webp $out/share/pixmaps/inter-knot.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "inter-knot";
      exec = "inter-knot";
      icon = "inter-knot";
      desktopName = "绳网";
      comment = "绳网是一个游戏、技术交流平台";
      categories = [ "Network" ];
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "绳网是一个游戏、技术交流平台";
    homepage = "https://inot.top";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
