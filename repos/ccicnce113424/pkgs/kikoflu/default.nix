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
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [ mpv-unwrapped ];

  postFixup = ''
    wrapProgram $out/bin/KikoFlu \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ mpv-unwrapped ]}"
  '';

  postInstall = ''
    install -D assets/icons/app_icon.svg $out/share/icons/hicolor/scalable/apps/kikoflu.svg
  '';

  meta = {
    description = "Unofficial pixiv app";
    homepage = "https://github.com/wgh136/pixes";
    mainProgram = "KikoFlu";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.linux;
  };
})
