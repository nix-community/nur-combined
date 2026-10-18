{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  # the gtk3 wrapper hook is named wrapGAppsHook3 on recent nixpkgs and
  # wrapGAppsHook on older ones; take whichever the caller's nixpkgs provides
  wrapGAppsHook3 ? null,
  wrapGAppsHook ? null,
  dpkg,

  # ELF NEEDED sonames
  dbus,
  gtk3,
  libsoup_3,
  webkitgtk_4_1,

  # runtime env wrapped into the launcher
  gdk-pixbuf,
  glib-networking,
  gsettings-desktop-schemas,
  gst_all_1,
  libayatana-appindicator,
  librsvg,
  shared-mime-info,
}:

let
  wrapGAppsGtk3Hook = if wrapGAppsHook3 != null then wrapGAppsHook3 else wrapGAppsHook;

  # version/hash metadata rewritten by manager.py (see update.yml)
  sourceInfo = lib.importJSON ./source-info.json;
  hashInfo = sourceInfo.hashes.x86_64-linux.gnu;
  version = lib.removePrefix "v" sourceInfo.version;
  # same placeholders as manager.py; the template hardcodes the upstream
  # repo name ("GalgameManager") since it differs from this package's pname,
  # and "__bname__" is unusable (update path has no binary name)
  url = lib.replaceStrings
    [
      "__owner__"
      "__pname__"
      "__version__"
      "__bare_version__"
      "__targetSystem__"
    ]
    [
      sourceInfo.owner
      "galgamemanager"
      sourceInfo.version
      version
      hashInfo.targetSystem
    ]
    hashInfo.template;
in
assert wrapGAppsGtk3Hook != null;
stdenv.mkDerivation (finalAttrs: {
  pname = "galgamemanager";
  inherit version;

  src = fetchurl {
    inherit url;
    sha256 = hashInfo.sha256;
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsGtk3Hook
  ];

  buildInputs = [
    dbus
    gtk3
    libayatana-appindicator
    libsoup_3
    webkitgtk_4_1
    # runtime-only: schemas, gio modules, image loaders, gst plugins
    gdk-pixbuf
    glib-networking
    gsettings-desktop-schemas
    librsvg
    shared-mime-info
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 usr/bin/GalgameManager $out/bin/GalgameManager
    # Tray icon lib is dlopen'ed ("libayatana-appindicator3.so.1"), not a
    # NEEDED entry, so autoPatchelf ignores it; turn it into a real DT_NEEDED
    # to get it RPATH-resolved instead of leaking LD_LIBRARY_PATH.
    patchelf --add-needed libayatana-appindicator3.so.1 $out/bin/GalgameManager

    install -Dm644 usr/share/icons/hicolor/32x32/apps/GalgameManager.png \
      $out/share/icons/hicolor/32x32/apps/GalgameManager.png
    install -Dm644 usr/share/icons/hicolor/128x128/apps/GalgameManager.png \
      $out/share/icons/hicolor/128x128/apps/GalgameManager.png
    install -Dm644 "usr/share/icons/hicolor/256x256@2/apps/GalgameManager.png" \
      "$out/share/icons/hicolor/256x256@2/apps/GalgameManager.png"

    substituteInPlace usr/share/applications/GalgameManager.desktop \
      --replace-fail "Categories=" "Categories=Game;Utility;"
    install -Dm644 usr/share/applications/GalgameManager.desktop \
      $out/share/applications/GalgameManager.desktop

    runHook postInstall
  '';

  gappsWrapperArgs = [
    "--set GDK_PIXBUF_MODULE_FILE ${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    "--suffix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules"
    "--suffix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
        with gst_all_1;
        [
          gstreamer
          gst-plugins-base
          gst-plugins-good
          gst-libav
        ]
      )
    }"
    "--suffix XDG_DATA_DIRS : ${shared-mime-info}/share"
  ];

  meta = {
    description = "Manage and sync your galgames";
    homepage = "https://github.com/lxl66566/GalgameManager";
    license = lib.licenses.mit;
    maintainers = [ "lxl66566" ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "GalgameManager";
  };
})
