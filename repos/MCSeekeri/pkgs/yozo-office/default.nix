{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  libice,
  libsm,
  libx11,
  libxau,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxshmfence,
  libxt,
  libxtst,
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
  libxkbcommon,
  zlib,
  e2fsprogs,
  cairo,
  bzip2,
  libmng,
  sane-backends,
  twolame,
  pango,
  gtk3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yozo-office";
  version = "9.0.6589.141ZH.S1";

  src = fetchurl {
    url = "https://dl.yozosoft.com/yozo/project/file/20251224_134417_869690/yozo-office_${finalAttrs.version}_amd64.deb";
    hash = "sha256-SVN18tEi+zYsp965cfgApgkJk963fbtK6GYk3K4JhWc=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libx11
    libxau
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
    libxt
    libxtst
    libxcb
    libice
    libsm
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
    libxkbcommon
    zlib
    stdenv.cc.cc.lib
    e2fsprogs
    cairo
    bzip2
    libmng
    sane-backends
    twolame
    pango
    gtk3
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libprotobuf-lite.so.11"
    "libSDL-1.2.so.0"
    "liba52-0.7.4.so"
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec $out/bin
    cp -r opt/apps/Yozo_Office $out/libexec/

    makeWrapper ${lib.placeholder "out"}/libexec/Yozo_Office/Yozo_Writer.bin $out/bin/yozow \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/Yozo_Office/Lib"
    makeWrapper ${lib.placeholder "out"}/libexec/Yozo_Office/Yozo_Calc.bin $out/bin/yozoc \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/Yozo_Office/Lib"
    makeWrapper ${lib.placeholder "out"}/libexec/Yozo_Office/Yozo_Impress.bin $out/bin/yozoi \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/Yozo_Office/Lib"
    makeWrapper ${lib.placeholder "out"}/libexec/Yozo_Office/Yozo_Office.bin $out/bin/yozo \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/Yozo_Office/Lib"
    makeWrapper ${lib.placeholder "out"}/libexec/Yozo_Office/xReader/xReader $out/bin/yozor \
      --set LD_LIBRARY_PATH "${lib.placeholder "out"}/libexec/Yozo_Office/xReader"

    mkdir -p $out/share/applications
    for d in usr/share/applications/*.desktop; do
      sed -e "s|/usr/bin/yozow|${lib.placeholder "out"}/bin/yozow|g" \
          -e "s|/usr/bin/yozoc|${lib.placeholder "out"}/bin/yozoc|g" \
          -e "s|/usr/bin/yozoi|${lib.placeholder "out"}/bin/yozoi|g" \
          -e "s|/usr/bin/yozor|${lib.placeholder "out"}/bin/yozor|g" \
          -e "s|/usr/bin/yozo |${lib.placeholder "out"}/bin/yozo |g" \
          -e "s|/usr/bin/yozo$|${lib.placeholder "out"}/bin/yozo|g" \
          "$d" > $out/share/applications/$(basename "$d")
    done

    mkdir -p $out/share/icons/hicolor
    cp -r usr/share/icons/hicolor/* $out/share/icons/hicolor/ 2>/dev/null || true

    runHook postInstall
  '';

  meta = {
    description = "MS Office compatible office suite";
    homepage = "https://www.yozosoft.com/product-officelinux.html";
    license = lib.licenses.unfree;
    mainProgram = "yozo";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
