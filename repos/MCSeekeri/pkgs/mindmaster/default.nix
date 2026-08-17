{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  qt5,
  libx11,
  libxcb,
  libxdamage,
  libxext,
  libxfixes,
  libxrender,
  libxshmfence,
  alsa-lib,
  at-spi2-core,
  cups,
  libdrm,
  expat,
  fontconfig,
  freetype,
  mesa,
  libglvnd,
  krb5,
  nss,
  nspr,
  postgresql,
  libxkbcommon,
  zlib,
  e2fsprogs,
  pulseaudio,
  speechd,
  xz,
  gtk3,
  pango,
  gdk-pixbuf,
  cairo,
  systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mindmaster";
  version = "10.8.0";

  src = fetchurl {
    url = "https://cc-download.edrawsoft.cn/mindmaster_cn_full5420.deb";
    hash = "sha256-Px0yUSSCarflSgS0U1Sw1GhSReZT5oKZNvGH1V/M9lk=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtsvg
    qt5.qtdeclarative
    qt5.qtquickcontrols2
    qt5.qt3d
    qt5.qtwebchannel
    qt5.qtmultimedia
    qt5.qtlocation
    qt5.qtpositioning
    qt5.qtsensors
    qt5.qtserialport
    qt5.qtserialbus
    qt5.qtspeech
    qt5.qtgamepad
    qt5.qttools
    qt5.qtwebsockets
    qt5.qtx11extras
    libx11
    libxdamage
    libxext
    libxfixes
    libxrender
    libxcb
    libxshmfence
    alsa-lib
    at-spi2-core
    cups
    libdrm
    expat
    fontconfig
    freetype
    mesa
    libglvnd
    krb5
    nss
    nspr
    postgresql.lib
    libxkbcommon
    zlib
    stdenv.cc.cc.lib
    e2fsprogs
    pulseaudio
    speechd
    xz
    gtk3
    pango
    gdk-pixbuf
    cairo
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libmysqlclient.so.18"
    "libQt5WebEngine.so.5"
    "libQt5WebEngineCore.so.5"
    "libQt5WebEngineWidgets.so.5"
    "liblber-2.4.so.2"
    "libldap-2.4.so.2"
  ];

  dontConfigure = true;
  dontBuild = true;
  dontWrapQtApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec $out/bin
    cp -r opt/MindMaster-10 $out/libexec/

    rm -f $out/libexec/MindMaster-10/lib/libQt5*.so*

    rm -rf $out/libexec/MindMaster-10/plugins/bearer \
      $out/libexec/MindMaster-10/plugins/platforms \
      $out/libexec/MindMaster-10/plugins/platforminputcontexts \
      $out/libexec/MindMaster-10/plugins/platformthemes \
      $out/libexec/MindMaster-10/plugins/iconengines \
      $out/libexec/MindMaster-10/plugins/imageformats

    makeWrapper ${lib.placeholder "out"}/libexec/MindMaster-10/MindMaster $out/bin/mindmaster \
      --set QT_QPA_PLATFORM "xcb" \
      --set QT_PLUGIN_PATH "${qt5.qtbase}/lib/qt-5.15.19/plugins" \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/MindMaster-10/lib/:${systemdLibs}/lib"

    install -Dm644 usr/share/icons/hicolor/*/apps/mindmaster.png \
      -t $out/share/icons/hicolor/ 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/scalable/apps/mindmaster.svg \
      $out/share/icons/hicolor/scalable/apps/mindmaster.svg 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/*/mimetypes/application-x-emmx.png \
      -t $out/share/icons/hicolor/ 2>/dev/null || true

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "mindmaster";
    exec = "mindmaster %F";
    icon = "mindmaster";
    desktopName = "亿图脑图MindMaster";
    comment = "亿图脑图MindMaster - 跨平台思维导图软件";
    categories = [ "Office" ];
    mimeTypes = [ "application/x-emmx" ];
  };

  postInstall = ''
    install -Dm644 ${finalAttrs.desktopItem}/share/applications/*.desktop \
      $out/share/applications/mindmaster.desktop
  '';

  meta = {
    description = "Cross-platform mind mapping software";
    homepage = "https://www.edrawsoft.cn/mindmaster/";
    license = lib.licenses.unfree;
    mainProgram = "mindmaster";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
