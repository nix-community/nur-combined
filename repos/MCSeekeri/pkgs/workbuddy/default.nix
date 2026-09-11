{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
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
  version = "5.4.5";

  src = fetchurl {
    url = "https://software.openkylin.top/openkylin/yangtze/pool/main/deb/workbuddy/workbuddy_${finalAttrs.version}_amd64.deb";
    hash = "sha256-eHGOSZNf64IVfHr8roZs+6Bt7sNLLbNlxjarazft+fQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
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

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin
    cp -r opt/apps/workbuddy $out/opt/workbuddy

    makeWrapper ${lib.placeholder "out"}/opt/workbuddy/workbuddy $out/bin/workbuddy \
      --prefix LD_LIBRARY_PATH : "${lib.placeholder "out"}/opt/workbuddy" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --add-flags "--no-sandbox" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    mkdir -p $out/share/applications
    install -Dm644 usr/share/applications/workbuddy.desktop $out/share/applications/workbuddy.desktop
    substituteInPlace $out/share/applications/workbuddy.desktop \
      --replace "/opt/apps/workbuddy/workbuddy" "${lib.placeholder "out"}/bin/workbuddy"

    cp -r usr/share/icons $out/share/icons

    runHook postInstall
  '';

  meta = {
    description = "Tencent WorkBuddy desktop client (腾讯 WorkBuddy Linux 桌面端)";
    homepage = "https://copilot.tencent.com/work/";
    downloadPage = "https://software.openkylin.top/openkylin/yangtze/pool/main/deb/workbuddy/";
    license = lib.licenses.unfree;
    mainProgram = "workbuddy";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
