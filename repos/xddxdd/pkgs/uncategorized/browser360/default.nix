{
  sources,
  lib,
  stdenv,
  writeShellScript,
  buildFHSEnv,
  runCommand,
  # Dependencies
  alsa-lib,
  apr,
  aprutil,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  curl,
  dbus,
  dmidecode,
  e2fsprogs,
  expat,
  fontconfig,
  freetype,
  fribidi,
  gdk-pixbuf,
  glib,
  gnome2,
  gnutls,
  graphite2,
  gtk2,
  gtk3,
  harfbuzz,
  icu63,
  krb5,
  libdrm,
  libgcrypt,
  libGLU,
  libglvnd,
  libidn2,
  libinput,
  libjpeg,
  libpng,
  libpsl,
  libpulseaudio,
  libssh2,
  libthai,
  libxcrypt-legacy,
  libxkbcommon,
  mesa,
  mtdev,
  nghttp2,
  nspr,
  nss,
  openldap,
  openssl_1_1,
  pango,
  pcre2,
  qt5,
  rtmpdump,
  udev,
  util-linux,
  xorg,
  ...
}:
let
  libraries = [
    alsa-lib
    apr
    aprutil
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    curl
    dbus
    dmidecode
    e2fsprogs
    expat
    fontconfig
    freetype
    fribidi
    gdk-pixbuf
    glib
    gnome2.gtkglext
    gnutls
    graphite2
    gtk2
    gtk3
    harfbuzz
    icu63
    krb5
    libdrm
    libgcrypt
    libGLU
    libglvnd
    libidn2
    libinput
    libjpeg
    libpng
    libpsl
    libpulseaudio
    libssh2
    libthai
    libxcrypt-legacy
    libxkbcommon
    mesa
    mtdev
    nghttp2
    nspr
    nss
    openldap
    openssl_1_1
    pango
    pcre2
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qtsvg
    qt5.qtx11extras
    rtmpdump
    udev
    util-linux
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXt
    xorg.libXtst
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
  ];

  currentArchSource =
    if stdenv.isx86_64 then
      sources.browser360-amd64
    else if stdenv.isAarch64 then
      sources.browser360-arm64
    else
      throw "Unsupported architecture";

  distPkg = stdenv.mkDerivation {
    pname = "browser360-dist";
    inherit (currentArchSource) version src;

    dontFixup = true;

    unpackPhase = ''
      ar x $src
      tar xf data.tar.xz
    '';

    postInstall = ''
      mkdir -p $out/opt $out/share
      mv opt/* $out/opt/
    '';
  };

  dmiInfo = runCommand "dmi.info" { } ''
    echo "[System]" >> $out
    echo "Manufacturer=`cat ${./dmi-id}/sys_vendor`" >> $out
    echo "ProductName=`cat ${./dmi-id}/product_name`" >> $out
    echo "Version=`cat ${./dmi-id}/product_version`" >> $out
    echo "SerialNumber=`cat ${./dmi-id}/product_serial`" >> $out
    echo "UUID=`cat ${./dmi-id}/product_uuid`" >> $out
    echo >> $out
    echo "[BaseBoard]" >> $out
    echo "Manufacturer=`cat ${./dmi-id}/board_vendor`" >> $out
    echo "ProductName=`cat ${./dmi-id}/board_name`" >> $out
    echo "Version=`cat ${./dmi-id}/board_version`" >> $out
    echo "SerialNumber=`cat ${./dmi-id}/board_serial`" >> $out
  '';

  fhs = buildFHSEnv {
    name = "browser360";
    targetPkgs = pkgs: libraries;
    runScript = builtins.toString (
      writeShellScript "browser360" ''
        mkdir -p /var/lib/browser360
        cp ${distPkg}/opt/apps/com.360.browser-stable/files/components/professional.qcert /var/lib/browser360/professional.qcert
        chmod 666 /var/lib/browser360/professional.qcert
        cp ${dmiInfo} /var/lib/browser360/dmi.info
        chmod 666 /var/lib/browser360/dmi.info

        mkdir -p /apps-data/private/com.360.browser-stable
        cp ${distPkg}/opt/apps/com.360.browser-stable/files/components/professional.qcert /apps-data/private/com.360.browser-stable/professional.qcert
        chmod 666 /apps-data/private/com.360.browser-stable/professional.qcert
        cp ${dmiInfo} /apps-data/private/com.360.browser-stable/dmi.info
        chmod 666 /apps-data/private/com.360.browser-stable/dmi.info

        exec /opt/apps/com.360.browser-stable/files/browser360 "$@"
      ''
    );
    extraBwrapArgs = [
      "--tmpfs /opt"
      "--ro-bind ${distPkg}/opt /opt"
      "--tmpfs /var"
      "--tmpfs /apps-data"
      "--ro-bind ${./dmi-id} /sys/devices/virtual/dmi/id"
    ];

    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
    unshareCgroup = false;
  };
in
stdenv.mkDerivation {
  pname = "browser360";
  inherit (currentArchSource) version;

  dontUnpack = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s ${fhs}/bin/browser360 $out/bin/browser360

    # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=browser360-bin

    for _icons in 16x16 24x24 32x32 48x48 64x64 128x128 256x256; do
      mkdir -p "$out/share/icons/hicolor/''${_icons}/apps"
      install -Dm644 \
        "${distPkg}/opt/apps/com.360.browser-stable/files/product_logo_''${_icons/x*}.png" \
        "$out/share/icons/hicolor/''${_icons}/apps/com.360.browser-stable.png"
    done

    mkdir -p "$out/share/applications"
    install -Dm644 \
      "${distPkg}/opt/apps/com.360.browser-stable/entries/applications/com.360.browser-stable.desktop" \
      "$out/share/applications/com.360.browser-stable.desktop"
    sed -E -i \
      "s|Exec=/opt/apps/com.360.browser-stable/files/com.360.browser|Exec=$out/bin/browser360|g" \
      "$out/share/applications/com.360.browser-stable.desktop"
  '';

  meta = with lib; {
    description = "360 Browser";
    homepage = "https://browser.360.net/gc/index.html";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
