{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  qt5,
  curl,
  sqlite,
  nss,
  nspr,
  lcms2,
  alsa-lib,
  libxslt,
  libxcomposite,
  freetype,
  libglvnd,
  cups,
  libxdamage,
  libtiff,
  libdrm,
  libice,
  libxshmfence,
  xcbutilimage,
  libxxf86vm,
  libxkbcommon,
  libsm,
  xcbutilwm,
  fontconfig,
  harfbuzz,
  xcbutilrenderutil,
  expat,
  hicolor-icon-theme,
  mesa,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gstarcad";
  version = "27.0.1";

  src = fetchurl {
    url = "https://official-cn.gstarcad.cn/linux/2027/gstarsoft.gstarcad2027_${finalAttrs.version}_715amd64.deb";
    hash = "sha256-TsnApLwBaBoqNDAXkomMy+gB2TtiCYJZJlgnZAjn4ow=";
    curlOptsList = [
      "-H"
      "Referer: https://www.gstarcad.com/download-thanks/linux/207/1/262/"
    ];
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtsvg
    curl
    sqlite
    nss
    nspr
    lcms2
    alsa-lib
    libxslt
    libxcomposite
    freetype
    libglvnd
    cups
    libxdamage
    libtiff
    libdrm
    libice
    libxshmfence
    xcbutilimage
    libxxf86vm
    libxkbcommon
    libsm
    xcbutilwm
    fontconfig
    harfbuzz
    xcbutilrenderutil
    expat
    hicolor-icon-theme
    mesa
  ];

  dontConfigure = true;
  dontBuild = true;
  dontWrapQtApps = true;

  autoPatchelfIgnoreMissingDeps = [
    "BimDb.gdx"
    "GcDbConstraints.gdx"
    "GcDgnLS.gdx"
    "GcGeolocationObj.gdx"
    "GcModelDocObj.gdx"
    "GcModelerGeometry.gdx"
    "GcRemoteDebug.grx"
    "GcSpatialReference.gdx"
    "GcWinEmu.grx"
    "IAecDbObject.grx"
    "IElecDbObject.grx"
    "IExtDbObject.grx"
    "IHvacDbObject.grx"
    "IMepDbObject.grx"
    "IWtDbObject.grx"
    "Ifc2Dwg.gdx"
    "IfcBrepBuilder.gdx"
    "Iges2Dwg.gdx"
    "IgesBrepBuilder.gdx"
    "InMemoryDatabase.gdx"
    "Step2Dwg.gdx"
    "StepBrepBuilder.gdx"
    "gcbr.gdx"
    "gcdgn.gdx"
    "gcdyn.gdx"
    "sdai.gdx"
    "libpython3.5m.so.1.0"
    "libpython3.6m.so.1.0"
    "libpython3.7m.so.1.0"
    "libpython3.8.so.1.0"
    "libtiff.so.5"
    "libglapi.so.0"
    "liblttng-ust.so.0"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec $out/bin
    cp -r opt/apps/gstarsoft.gstarcad2027 $out/libexec/

    rm -rf $out/libexec/gstarsoft.gstarcad2027/files/systemlibs/GL

    makeWrapper ${lib.placeholder "out"}/libexec/gstarsoft.gstarcad2027/files/gclauncher.sh $out/bin/gstarcad \
      --set LD_LIBRARY_PATH "${libglvnd}/lib:${mesa}/lib"

    install -Dm644 usr/share/icons/hicolor/scalable/apps/gstarsoft.gstarcad2027.svg \
      $out/share/icons/hicolor/scalable/apps/gstarsoft.gstarcad2027.svg
    install -Dm644 usr/share/icons/hicolor/32x32/mimetypes/*.png \
      $out/share/icons/hicolor/32x32/mimetypes/ 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/64x64/mimetypes/*.png \
      $out/share/icons/hicolor/64x64/mimetypes/ 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/128x128/mimetypes/*.png \
      $out/share/icons/hicolor/128x128/mimetypes/ 2>/dev/null || true
    install -Dm644 usr/share/icons/hicolor/256x256/mimetypes/*.png \
      $out/share/icons/hicolor/256x256/mimetypes/ 2>/dev/null || true

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "gstarcad";
    exec = "gstarcad %F";
    icon = "gstarsoft.gstarcad2027";
    desktopName = "GstarCAD 2027";
    genericName = "GstarCAD 2027";
    comment = "GstarCAD 2027";
    categories = [
      "Graphics"
      "Viewer"
    ];
    mimeTypes = [
      "image/vnd.dwg"
      "application/dwg"
      "image/vnd.dxf"
      "application/dxf"
      "application/dwf"
      "application/dwfx"
      "application/dwt"
      "model/vnd.dwf"
      "model/vnd.dwfx"
    ];
  };

  postInstall = ''
    install -Dm644 ${finalAttrs.desktopItem}/share/applications/*.desktop \
      $out/share/applications/gstarcad.desktop
  '';

  meta = {
    description = "Professional 2D/3D CAD software";
    homepage = "https://www.gstarcad.com/cad_linux";
    license = lib.licenses.unfree;
    mainProgram = "gstarcad";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
