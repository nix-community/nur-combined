{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  krb5,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXScrnSaver,
  libXtst,
  libdrm,
  libffi,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libxcb,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  openssl,
  pango,
  systemdLibs,
  xdg-utils,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "workbuddy";
  version = "5.11.3.43806934-ecace0f7";

  src = fetchurl {
    url = "https://github.com/acgq/workbuddy-linux/releases/download/port-v${finalAttrs.version}-r2/workbuddy_${finalAttrs.version}-2_amd64.tar.gz";
    hash = "sha256-jhzoyKPIYJX73DOTxm4sylq/nJeQS6MsI91BEHZNrcU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    krb5
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXScrnSaver
    libXtst
    libdrm
    libffi
    libgbm
    libnotify
    libsecret
    libuuid
    libxcb
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    systemdLibs
    zlib
    stdenv.cc.cc.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  autoPatchelfIgnoreMissingDeps = [
    "libc++.so.9.0"
    "libc++abi.so.6.0"
    "libpthread.so.26.1"
    "libm.so.10.1"
    "libc.musl-x86_64.so.1"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin
    cp -r . $out/opt/WorkBuddy

    makeWrapper ${lib.placeholder "out"}/opt/WorkBuddy/launch-workbuddy $out/bin/workbuddy \
      --set NODE_ENV production \
      --prefix LD_LIBRARY_PATH : "${lib.placeholder "out"}/opt/WorkBuddy" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --add-flags "--no-sandbox" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    install -Dm644 $out/opt/WorkBuddy/resources/app.asar.unpacked/resources/icon.png \
      $out/share/icons/hicolor/1024x1024/apps/workbuddy.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "workbuddy";
      exec = "workbuddy %U";
      icon = "workbuddy";
      desktopName = "WorkBuddy";
      comment = "WorkBuddy AI agents";
      categories = [ "Office" ];
      mimeTypes = [ "x-scheme-handler/workbuddy" ];
      startupWMClass = "workbuddy";
    })
  ];

  meta = {
    description = "Tencent WorkBuddy desktop client (腾讯 WorkBuddy macOS 桌面端的 Linux 移植版本)";
    homepage = "https://github.com/acgq/workbuddy-linux";
    license = lib.licenses.unfree;
    mainProgram = "workbuddy";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
