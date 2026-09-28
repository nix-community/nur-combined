{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libGL,
  libgbm,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxkbcommon,
  nss,
  nspr,
  pango,
  systemd,
  vulkan-loader,
  wayland,
}:
let
  source = import ./sources/x86_64-linux.nix;
  runtimeLibraries = [
    libGL
    libnotify
    libpulseaudio
    libsecret
    libxkbcommon
    systemd
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "folia-major-bin";
  inherit (source) version;
  src = fetchurl { inherit (source) url hash; };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxkbcommon
    nss
    nspr
    pango
    stdenv.cc.cc.lib
  ]
  ++ runtimeLibraries;

  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/folia-major" "$out/bin"
    cp -r . "$out/lib/folia-major/"

    # Koffi ships both libc variants; NixOS uses the glibc build.
    rm -r "$out/lib/folia-major/resources/app.asar.unpacked/node_modules/@koromix/koffi-linux-x64/musl_x64"
    install -Dm444 resources/linux/folia-major.desktop \
      "$out/share/applications/folia-major.desktop"
    substituteInPlace "$out/share/applications/folia-major.desktop" \
      --replace-fail '__APP_PATH__' "$out/bin/folia-major" \
      --replace-fail '__ICON_PATH__' 'folia-major'
    install -Dm444 resources/icon.png "$out/share/icons/hicolor/512x512/apps/folia-major.png"
    runHook postInstall
  '';

  preFixup = ''
    # These libraries are loaded with dlopen, including by the wallpaper helper.
    makeWrapper "$out/lib/folia-major/folia-major" "$out/bin/folia-major" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Music player with immersive animated lyrics and local and online music support";
    homepage = "https://github.com/chthollyphile/folia-major";
    changelog = "https://github.com/chthollyphile/folia-major/releases/tag/v${source.version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "folia-major";
    platforms = [ "x86_64-linux" ];
  };
}
