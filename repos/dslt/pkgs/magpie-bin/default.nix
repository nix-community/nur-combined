{
  lib,
  stdenv,
  sources,
  patchelf,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  gdk-pixbuf,
  glib,
  fontconfig,
  libx11,
  wayland,
  libGL,
  xdg-utils,
  desktop-file-utils,
}:

let
  source = if stdenv.hostPlatform.isAarch64 then sources.magpie-bin-aarch64 else sources.magpie-bin-x86_64;

  # The icon is extracted by the magpie source record: the release asset is a
  # bare ELF binary and carries no menu-entry artwork of its own.
  icon = sources.magpie.extract."internal/gui/icon-256.png";

  # autoPatchelfHook writes a RUNPATH into this Go binary and corrupts its
  # program headers (the loader segfaults before main). Only the interpreter
  # is patched; the libraries come from the wrapper's LD_LIBRARY_PATH.
  runtimeLibraries = [
    gtk3
    webkitgtk_4_1
    libsoup_3
    gdk-pixbuf
    glib
    fontconfig
    libx11
    wayland
    libGL
    stdenv.cc.cc.lib
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "magpie-bin";
  inherit (source) version;

  src = source.src;

  nativeBuildInputs = [
    patchelf
    makeWrapper
    copyDesktopItems
  ];

  # The release binary is linked against GTK 3 and WebKitGTK 4.1; these are
  # the direct libraries ldd names, plus libGL for WebKit's dlopen at runtime.
  buildInputs = runtimeLibraries;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/libexec/magpie
    install -Dm644 ${icon} $out/share/icons/hicolor/256x256/apps/magpie.png

    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      $out/libexec/magpie

    makeWrapper $out/libexec/magpie $out/bin/magpie \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
      --prefix PATH : ${lib.makeBinPath [
        xdg-utils
        desktop-file-utils
      ]}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "magpie";
      exec = "magpie %u";
      icon = "magpie";
      desktopName = "magpie";
      comment = "Every agent's model. One place.";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "x-scheme-handler/magpie" ];
      startupWMClass = "magpie";
    })
  ];

  meta = {
    description = "Local gateway and desktop app that puts every AI coding agent's model in one place, prebuilt binary release";
    homepage = "https://github.com/yetone/magpie";
    changelog = "https://github.com/yetone/magpie/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "magpie";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
