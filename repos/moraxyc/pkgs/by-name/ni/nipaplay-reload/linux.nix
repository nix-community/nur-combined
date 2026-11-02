{
  stdenv,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  patchelf,

  alsa-lib,
  atk,
  cairo,
  fontconfig,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk3,
  harfbuzz,
  ayatana-ido,
  libGL,
  libayatana-appindicator,
  libayatana-indicator,
  libdbusmenu,
  libdrm,
  libepoxy,
  libevdev,
  libgbm,
  keybinder3,
  libpulseaudio,
  libva,
  libvdpau,
  libx11,
  libxkbcommon,
  mpv-unwrapped,
  pango,
  vulkan-loader,
  wayland,

  meta,
  src,
  pname,
  version,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit
    meta
    src
    pname
    version
    ;

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    patchelf
  ];

  buildInputs = [
    alsa-lib
    atk
    cairo
    fontconfig
    gdk-pixbuf
    glib
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk3
    harfbuzz
    ayatana-ido
    libGL
    libayatana-appindicator
    libayatana-indicator
    libdbusmenu
    libdrm
    libepoxy
    libevdev
    libgbm
    keybinder3
    libpulseaudio
    libva
    libvdpau
    libx11
    libxkbcommon
    pango
    vulkan-loader
    wayland
    stdenv.cc.cc.lib
    # libmpv.so.2 is provided here instead of the bundled Ubuntu build
    mpv-unwrapped
  ];

  # Loaded with dlopen at runtime
  runtimeDependencies = [
    libayatana-appindicator
    mpv-unwrapped
    vulkan-loader
  ];

  # libjvm.so is only needed by the optional jni bridge (dartjni)
  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  dontConfigure = true;
  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = "io.github.MCDFsteve.NipaPlay-Reload";
      desktopName = "NipaPlay";
      comment = finalAttrs.meta.description;
      exec = "${finalAttrs.meta.mainProgram} %U";
      icon = "io.github.MCDFsteve.NipaPlay-Reload";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
      ];
      startupWMClass = "io.github.MCDFsteve.NipaPlay-Reload";
    })
  ];

  installPhase = ''
    runHook preInstall

    # Use libmpv from nixpkgs instead of the bundled one, whose
    # ffmpeg/libplacebo dependencies are not shipped in the archive
    rm lib/libmpv.so*

    # Only a malloc override linked in by upstream; no mimalloc symbols are used
    patchelf --remove-needed libmimalloc.so.2 NipaPlay

    mkdir -p $out/opt/nipaplay
    cp -r NipaPlay data lib $out/opt/nipaplay/

    makeWrapper $out/opt/nipaplay/NipaPlay $out/bin/${finalAttrs.meta.mainProgram} \
      --set-default GTK_CSD 0

    install -Dm644 data/flutter_assets/assets/images/logo512.png \
      $out/share/icons/hicolor/512x512/apps/io.github.MCDFsteve.NipaPlay-Reload.png

    runHook postInstall
  '';
})
