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
  gtk3,
  pango,
  gdk-pixbuf,
  cairo,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "edrawmax";
  version = "15.0.6";

  src = fetchurl {
    url = "https://cc-download.wondershare.cc/business/prd/edrawmax_${finalAttrs.version}_cn.deb";
    hash = "sha256-qGEtBGJNB6EvyIg1wjoQC2kqTTlu1UjDHMcludi3kEE=";
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
    qt5.qtsensors
    qt5.qtserialport
    qt5.qtgamepad
    qt5.qttools
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
    cp -r opt/apps/edrawmax $out/libexec/

    makeWrapper ${lib.placeholder "out"}/libexec/edrawmax/EdrawMax $out/bin/edrawmax \
      --set QT_QPA_PLATFORM "" \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/edrawmax/lib/:${udev}/lib"

    install -Dm644 usr/share/icons/hicolor/*/apps/edrawmax.png \
      -t $out/share/icons/hicolor/ 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/32x32/mimetypes/application-x-eddx.png \
      $out/share/icons/hicolor/32x32/mimetypes/application-x-eddx.png 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/64x64/mimetypes/application-x-eddx.png \
      $out/share/icons/hicolor/64x64/mimetypes/application-x-eddx.png 2>/dev/null || true

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "edrawmax";
    exec = "edrawmax %F";
    icon = "edrawmax";
    desktopName = "EdrawMax";
    comment = "万兴图示 - 全类型图形图表设计工具";
    categories = [ "Office" ];
    mimeTypes = [ "application/x-eddx" ];
  };

  postInstall = ''
    install -Dm644 ${finalAttrs.desktopItem}/share/applications/*.desktop \
      $out/share/applications/edrawmax.desktop
  '';

  meta = {
    description = "All-in-one diagram software";
    homepage = "https://www.edrawsoft.cn/edrawmax/";
    license = lib.licenses.unfree;
    mainProgram = "edrawmax";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
