{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-core,
  bzip2,
  libtool,
  libxkbcommon,
  nspr,
  libgbm,
  libtiff,
  udev,
  gtk3,
  libsForQt5,
  libmysqlclient,
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
  pkgVersion = "12.1.2.22571";
  url = "https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/${lib.last (lib.splitVersion pkgVersion)}/wps-office_${pkgVersion}.AK.preread.sw_480057_amd64.deb";
  hash = "sha256-oppJqiUEe/0xEWxgKVMPMFngjQ0e5xaac6HuFVIBh8I=";
  uri = builtins.replaceStrings [ "https://wps-linux-personal.wpscdn.cn" ] [ "" ] url;
  securityKey = "7f8faaaa468174dc1c9cd62e5f218a5b";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wpsoffice-cn";
  version = pkgVersion;

  src =
    runCommandLocal "wps-office_${finalAttrs.version}.AK.preread.sw_480057_amd64.deb"
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

        curl --retry 3 --retry-delay 3 "${url}?t=$timestamp10&k=$md5hash" > $out
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
    bzip2
    libtool
    libjpeg
    libxkbcommon
    nspr
    libgbm
    libtiff
    udev
    gtk3
    libusb1
    libsForQt5.qtbase
    libmysqlclient
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
  ];

  dontWrapQtApps = true;

  runtimeDependencies = map lib.getLib [
    cups
    pango
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libpeony.so.3"
    "libmysqlclient.so.18"
  ];

  installPhase = ''
    runHook preInstall
    prefix=$out/opt/kingsoft/wps-office
    mkdir -p $out
    cp -r opt $out
    cp -r usr/{bin,share} $out
    for i in wps wpp et wpspdf; do
      substituteInPlace $out/bin/$i --replace-quiet /opt/kingsoft/wps-office $prefix
    done
    for i in $out/share/applications/*; do
      substituteInPlace $i --replace-quiet /usr/bin $out/bin
    done
    runHook postInstall
  '';

  preFixup = ''
    # fix libbz2 dangling symlink
    ln -sf ${bzip2.out}/lib/libbz2.so $out/opt/kingsoft/wps-office/office6/libbz2.so
    # remove libmysqlclient dependency
    # patchelf --remove-needed libmysqlclient.so.18 $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
    # dlopen dependency
    patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
    # remove UKUI dependency
    # patchelf --remove-needed libpeony.so.3 $out/opt/kingsoft/wps-office/office6/libpeony-wpsprint-menu-plugin.so
  '';

  meta = with lib; {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.com";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfreeRedistributable;
  };
})
