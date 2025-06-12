{
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  lib,
  fetchurl,
  callPackage,
  dpkg,
  # Dependencies
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  gdk-pixbuf,
  glib,
  gnome-themes-extra,
  gnome2,
  gtk2,
  libjpeg8,
  libpulseaudio,
  libvlc,
  nspr,
  nss,
  openssl_1_1,
  pango,
  pciutils,
  libqcef,
  qt5,
  taglib_1,
  udev,
  xorg,
}:
# Modified from:
# - https://github.com/NixOS-CN/flakes/blob/main/packages/netease-cloud-music/default.nix
# - https://github.com/Freed-Wu/nur-packages/blob/main/pkgs/applications/audio/netease-cloud-music/default.nix
let
  libnetease-patch = callPackage ./netease-patch.nix { };

  libraries = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    gdk-pixbuf
    glib
    gnome-themes-extra
    gnome2.GConf
    gtk2
    libjpeg8
    libnetease-patch
    libpulseaudio
    libvlc
    nspr
    nss
    openssl_1_1
    pango
    pciutils
    libqcef
    qt5.qtbase
    qt5.qtwebengine
    qt5.qtx11extras
    taglib_1
    udev
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "netease-cloud-music";
  version = "1.2.1";
  src = fetchurl {
    url = "http://d1.music.126.net/dmusic/netease-cloud-music_${finalAttrs.version}_amd64_ubuntu_20190428.deb";
    sha256 = "1fzc5xb3h17jcdg8w8xliqx2372g0wrfkcj8kk3wihp688lg1s8y";
    curlOpts = "-A 'Mozilla/5.0'";
  };

  unpackPhase = ''
    runHook preUnpack

    dpkg -x $src .

    runHook postUnpack
  '';

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    makeWrapper
    autoPatchelfHook
    dpkg
  ];
  buildInputs = libraries;

  # We will append QT wrapper args to our own wrapper
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 opt/netease/netease-cloud-music/netease-cloud-music $out/bin/netease-cloud-music

    mkdir -p $out/share
    cp -r usr/share/* $out/share/

    wrapProgram $out/bin/netease-cloud-music \
      "''${qtWrapperArgs[@]}" \
      --set QCEF_INSTALL_PATH "${libqcef}/lib/qcef" \
      --set QT_QPA_PLATFORM xcb \
      --set XDG_SESSION_TYPE x11 \
      --set LD_PRELOAD "${libnetease-patch}/lib/libnetease-patch.so" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "NetEase Cloud Music Linux Client (package script adapted from NixOS-CN and Freed-Wu)";
    homepage = "https://music.163.com";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    mainProgram = "netease-cloud-music";
  };
})
