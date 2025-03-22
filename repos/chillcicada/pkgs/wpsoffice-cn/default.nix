{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-core,
  libtool,
  libxkbcommon,
  nspr,
  libgbm,
  libtiff,
  udev,
  gtk3,
  libsForQt5,
  xorg,
  cups,
  pango,
  runCommandLocal,
  curl,
  coreutils,
  cacert,
  libjpeg,
  libusb1,
}:
let
  pkgVersion = "12.1.0.17900";
  url = "https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/${lib.last (lib.splitVersion pkgVersion)}/wps-office_${pkgVersion}_amd64.deb";
  hash = "sha256-i2EVCmDLE2gx7l2aAo+fW8onP/z+xlPIbQYwKhQ46+o=";
  uri = builtins.replaceStrings [ "https://wps-linux-personal.wpscdn.cn" ] [ "" ] url;
  securityKey = "7f8faaaa468174dc1c9cd62e5f218a5b";
in
stdenv.mkDerivation rec {
  pname = "wpsoffice";
  version = pkgVersion;

  src =
    runCommandLocal "wps-office_${version}_amd64.deb"
      {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = hash;

        nativeBuildInputs = [
          curl
          coreutils
        ];

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      }
      ''
        timestamp10=$(date '+%s')
        md5hash=($(echo -n "${securityKey}${uri}$timestamp10" | md5sum))

        curl \
        --retry 3 --retry-delay 3 \
        "${url}?t=$timestamp10&k=$md5hash" \
        > $out
      '';

  unpackCmd = "dpkg -x $src .";
  sourceRoot = ".";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    libtool
    libjpeg
    libxkbcommon
    nspr
    libgbm
    libtiff
    udev
    gtk3
    libusb1
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
    libsForQt5.qt5.qtbase
  ];

  dontWrapQtApps = true;

  runtimeDependencies = map lib.getLib [
    cups
    pango
  ];

  autoPatchelfIgnoreMissingDeps = [
    # distribution is missing libkappessframework.so
    "libkappessframework.so"
    # qt4 support is deprecated
    "libQtCore.so.4"
    "libQtNetwork.so.4"
    "libQtXml.so.4"
    "libuof.so"
  ];

  installPhase = ''
    runHook preInstall
    prefix=$out/opt/kingsoft/wps-office
    mkdir -p $out
    cp -r opt $out
    cp -r usr/* $out
    for i in wps wpp et wpspdf; do
      substituteInPlace $out/bin/$i \
        --replace /opt/kingsoft/wps-office $prefix
    done
    for i in $out/share/applications/*;do
      substituteInPlace $i \
        --replace /usr/bin $out/bin
    done
    runHook postInstall
  '';

  preFixup = ''
    # The following libraries need libtiff.so.5, but nixpkgs provides libtiff.so.6
    patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/kingsoft/wps-office/office6/{libpdfmain.so,libqpdfpaint.so,qt/plugins/imageformats/libqtiff.so,addons/pdfbatchcompression/libpdfbatchcompressionapp.so}
    patchelf --add-needed libtiff.so $out/opt/kingsoft/wps-office/office6/libwpsmain.so
    # Fix: Wrong JPEG library version: library is 62, caller expects 80
    patchelf --add-needed libjpeg.so $out/opt/kingsoft/wps-office/office6/libwpsmain.so
    # dlopen dependency
    patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
  '';

  meta = with lib; {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.com";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [
      mlatus
      th0rgal
      rewine
      pokon548
    ];
  };
}
