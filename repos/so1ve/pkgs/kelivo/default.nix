{
  lib,
  source ? callPackage ./source.nix { },
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  wrapGAppsHook3,
  atk,
  cairo,
  callPackage,
  fontconfig,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk3,
  harfbuzz,
  keybinder3,
  libayatana-appindicator,
  libepoxy,
  pango,
}:

let
  version = source.version;

  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ];
in
stdenv.mkDerivation {
  pname = "kelivo";
  inherit (source) src;
  inherit version;

  # The release archive has `kelivo`, `lib` and `data` at its top level.
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    cairo
    fontconfig
    gdk-pixbuf
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk3
    harfbuzz
    keybinder3
    libayatana-appindicator
    libepoxy
    pango
    stdenv.cc.cc.lib
  ];

  # `libdartjni.so` names a JVM in its rpath, but the Linux build never loads it:
  # it is absent from `data/flutter_assets/NativeAssetsManifest.json`.
  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/app/kelivo
    cp -r kelivo lib data $out/app/kelivo
    chmod +x $out/app/kelivo/kelivo

    mkdir -p $out/bin
    makeWrapper $out/app/kelivo/kelivo $out/bin/kelivo \
      --prefix LD_LIBRARY_PATH : "$out/app/kelivo/lib" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins
      }"

    install -Dm644 data/flutter_assets/assets/app_icon.png \
      $out/share/icons/hicolor/1024x1024/apps/kelivo.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "kelivo";
      exec = "kelivo %U";
      icon = "kelivo";
      desktopName = "Kelivo";
      startupWMClass = "com.psyche.kelivo";
      comment = "A Flutter LLM chat client";
      categories = [
        "Network"
        "Chat"
      ];
    })
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/kelivo
    test -f $out/share/applications/kelivo.desktop
    test -f $out/share/icons/hicolor/1024x1024/apps/kelivo.png

    runHook postInstallCheck
  '';

  meta = {
    description = "A Flutter LLM chat client";
    homepage = "https://github.com/Chevey339/kelivo";
    changelog = "https://github.com/Chevey339/kelivo/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "kelivo";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
