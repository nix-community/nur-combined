{
  sources,
  version,
  srcInfo,
  lib,
  flutter,
  mpv-unwrapped,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  imagemagick,
}:
flutter.buildFlutterApplication (finalAttrs: {
  inherit (sources) pname src;
  inherit version;
  inherit (srcInfo) pubspecLock;
  inherit (srcInfo) gitHashes;

  desktopItems = [
    (makeDesktopItem {
      name = "kikoflu";
      desktopName = "KikoFlu";
      genericName = "KikoFlu";
      exec = "KikoFlu %u";
      comment = finalAttrs.meta.description;
      terminal = false;
      categories = [ "Utility" ];
      keywords = [
        "Flutter"
        "Audio"
      ];
      icon = "kikoflu";
      startupWMClass = "com.meteor.kikoflu";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    imagemagick
  ];

  postFixup = ''
    wrapProgram $out/bin/KikoFlu \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ mpv-unwrapped ]}"
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/512x512/apps
    magick convert $src/assets/icons/app_icon_no_background.png -resize 512x512 $out/share/icons/hicolor/512x512/apps/kikoflu.png
  '';

  meta = {
    description = "Kikoeru Flutter app";
    homepage = "https://github.com/pa-jesusf/KikoFlu";
    mainProgram = "KikoFlu";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
