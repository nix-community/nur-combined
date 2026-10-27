{
  sources,
  version,
  pubspecLock,
  gitHashes,
  lib,
  flutter,
  mpv-unwrapped,
  makeDesktopItem,
  copyDesktopItems,
  autoPatchelfHook,
}:
flutter.buildFlutterApplication (finalAttrs: {
  inherit (sources) pname src;
  inherit version pubspecLock gitHashes;

  passthru.updateScript = [ ./update.sh ];

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
    autoPatchelfHook
  ];

  # media_kit loads libmpv through DynamicLibrary.open(), and the call site is
  # the bundled Dart VM (libflutter_linux_gtk.so) rather than the executable,
  # so runtimeDependencies (executables only) cannot cover it: the directory has
  # to be appended to the RUNPATH of every ELF in the bundle.
  appendRunpaths = [ (lib.makeLibraryPath [ mpv-unwrapped ]) ];

  postInstall = ''
    install -D assets/icons/app_icon_no_background.png $out/share/icons/kikoflu.png
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
