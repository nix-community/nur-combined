{
  lib,
  stdenv,
  autoPatchelfHook,
  # wpsoffice dependencies
  alsa-lib,
  libjpeg,
  libtool,
  libxkbcommon,
  nss,
  nspr,
  udev,
  gtk3,
  libgbm,
  libusb1,
  libsForQt5,
  xorg,
  cups,
  pango,
  unixODBC,
  libmysqlclient,
  # wpsoffice build dependencies
  runCommandLocal,
  curl,
  coreutils,
  cacert,
}:

let
  pname = "wpsoffice-cn";
  sources = import ./sources.nix;
  version = sources.version;

  fetch =
    {
      url,
      uri,
      hash,
    }:
    runCommandLocal "wpsoffice-cn-${version}-src"
      {
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
        readonly SECURITY_KEY="7f8faaaa468174dc1c9cd62e5f218a5b"

        timestamp10=$(date '+%s')
        md5hash=($(printf '%s' "$SECURITY_KEY${uri}$timestamp10" | md5sum))

        curl --retry 3 --retry-delay 3 "${url}?t=$timestamp10&k=$md5hash" > $out
      '';

  srcs = {
    x86_64-linux = fetch sources.x86_64;
  };

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation {
  inherit pname src version;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    libjpeg
    libtool
    libxkbcommon
    nss
    nspr
    udev
    gtk3
    libgbm
    libusb1
    unixODBC
    libsForQt5.qtbase
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
  ];

  dontWrapQtApps = true;

  stripAllList = [ "opt" ];

  runtimeDependencies = map lib.getLib [
    cups
    pango
  ];

  unpackPhase = ''
    # Unpack the .deb file
    ar x $src
    tar -xf data.tar.xz

    # Remove unneeded files
    rm -f usr/bin/misc
    rm -rf opt/kingsoft/wps-office/{desktops,INSTALL}
    rm -f opt/kingsoft/wps-office/office6/{libpeony-wpsprint-menu-plugin.so,libbz2.so,libjpeg.so*,libstdc++.so*,libgcc_s.so*,libodbc*.so*,libnss*.so*}
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp -r opt $out
    cp -r usr/{bin,share} $out

    for i in $out/bin/*; do
      substituteInPlace $i \
        --replace-fail /opt/kingsoft/wps-office $out/opt/kingsoft/wps-office
    done

    for i in $out/share/applications/*; do
      substituteInPlace $i \
        --replace-fail /usr/bin $out/bin
    done

    runHook postInstall
  '';

  preFixup = ''
    # dlopen dependency
    patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
    # libmysqlclient dependency
    patchelf --replace-needed libmysqlclient.so.18 libmysqlclient.so $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
    patchelf --add-rpath ${libmysqlclient}/lib/mariadb $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.com";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = licenses.unfree;
    maintainers = with maintainers; [
      mlatus
      th0rgal
      wineee
      pokon548
      chillcicada
    ];
  };
}
