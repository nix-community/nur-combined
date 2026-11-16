{
  alsa-lib,
  asar,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  cairo,
  callPackage,
  copyDesktopItems,
  cups,
  dbus,
  expat,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  lib,
  libgbm,
  libGL,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  makeShellWrapper,
  nspr,
  nss,
  pango,
  pipewire,
  source ? callPackage ./source.nix { },
  stdenv,
  systemdLibs,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "antigravity-hub";
  inherit (source) version src;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    asar
    autoPatchelfHook
    copyDesktopItems
    makeShellWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gsettings-desktop-schemas
    gtk3
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemdLibs
  ];

  runtimeDependencies = map lib.getLib [
    libnotify
    libpulseaudio
    libsecret
    pipewire
  ];

  appendRunpaths = [ "${lib.getLib libGL}/lib" ];
  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "antigravity-hub";
      desktopName = "Antigravity";
      comment = "Manage multiple autonomous agents across independent projects";
      exec = "antigravity %U";
      icon = "antigravity";
      categories = [ "Development" ];
      mimeTypes = [ "x-scheme-handler/antigravity" ];
      startupWMClass = "antigravity";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/antigravity
    cp -r . $out/share/antigravity

    asar extract-file resources/app.asar icon.png
    install -Dm644 icon.png $out/share/icons/hicolor/512x512/apps/antigravity.png

    runHook postInstall
  '';

  postFixup = ''
    makeShellWrapper $out/share/antigravity/antigravity $out/bin/antigravity \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --add-flags "--password-store=gnome-libsecret"
  '';

  meta = {
    description = "Desktop environment for managing multiple autonomous agents across independent projects";
    homepage = "https://antigravity.google";
    changelog = "https://antigravity.google/changelog";
    downloadPage = "https://antigravity.google/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "antigravity";
  };
}
