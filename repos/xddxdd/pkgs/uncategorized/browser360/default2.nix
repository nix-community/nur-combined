{
  sources,
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
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
  e2fsprogs,
  fontconfig,
  freetype,
  fribidi,
  gdk-pixbuf,
  glib,
  gnome2,
  gnutls,
  graphite2,
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
  pciutils,
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
    e2fsprogs
    fontconfig
    freetype
    fribidi
    gdk-pixbuf
    glib
    gnome2.gtkglext
    gnutls
    graphite2
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
    pciutils
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
in
stdenv.mkDerivation {
  pname = "browser360";
  version = "13.3.1012.21";
  src = fetchurl {
    url = "https://gedown.360safe.com/gc/signed_com.360.browser-stable_13.3.1012.21-1_amd64.deb";
    sha256 = "00nhx8yh549j7lksn8wk7wc1dyjd4mdzybjnhgp1p77ihy68nnxz";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    qt5.wrapQtAppsHook
  ];
  buildInputs = libraries;

  # We will append QT wrapper args to our own wrapper
  dontWrapQtApps = true;

  unpackPhase = ''
    ar x $src
    tar xf data.tar.xz
  '';

  postInstall = ''
    mkdir -p $out/opt $out/share
    mv opt/apps/com.360.browser-stable/files/* $out/opt/
    mv opt/apps/com.360.browser-stable/entries/applications $out/share/
    mv opt/apps/com.360.browser-stable/entries/icons $out/share/

    # Entrypoint
    mkdir -p $out/bin
    makeWrapper $out/opt/browser360 $out/bin/browser360 \
      "''${qtWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"
  '';
}
