{ stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  dpkg,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  fribidi,
  gdk-pixbuf,
  glib,
  gnutls,
  graphite2,
  gtk3,
  harfbuzz,
  libdrm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libuuid,
  libxkbcommon,
  libXi,
  libXext,
  libXfixes,
  libXdamage,
  libXcomposite,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libxshmfence,
  mesa,
  nss,
  pango,
  udev,
  xorg,
}:
let
  libraries = [
    alsa-lib at-spi2-atk at-spi2-core cairo cups dbus expat fontconfig freetype
    fribidi gdk-pixbuf glib gnutls graphite2 gtk3 harfbuzz libdrm libglvnd
    libnotify libpulseaudio libuuid libxkbcommon libXi libXext libXfixes
    libXdamage libXcomposite libXrandr libXrender libXScrnSaver libxshmfence
    mesa nss pango udev xorg.libxcb
  ];
in
stdenv.mkDerivation rec {
  pname = "dingtalk";
  version = "7.8.15.5102301";
  src = fetchurl {
    url = "https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release/com.alibabainc.dingtalk_${version}_amd64.deb";
    hash = "sha256-0k0g74h0di2z7a1mnygpxbgwcn8qqaihcl5zn65wz3a8wnih9xph";
  };
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    dpkg
  ];
  buildInputs = libraries;
  unpackPhase = ''
    runHook preUnpack
    dpkg -x $src .
    mv opt/apps/com.alibabainc.dingtalk/files ./dingtalk-files
    rm -f ./dingtalk-files/dingtalk_crash_report
    rm -f ./dingtalk-files/dingtalk_updater
    runHook postUnpack
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    mv ./dingtalk-files/* $out/lib/
    mkdir -p $out/bin
    install -Dm644 $out/lib/Resources/image/common/about/logo.png $out/share/pixmaps/dingtalk.png
    makeWrapper $out/lib/com.alibainc.dingtalk $out/bin/dingtalk \
      --chdir $out/lib \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
      --prefix XDG_DATA_DIRS : "${gdk-pixbuf}/share:${gtk3}/share:$out/share" \
      --prefix LD_PRELOAD : "$out/lib/libcef.so" \
      --set QT_QPA_PLATFORM "xcb" \
      --unset WAYLAND_DISPLAY \
      --set QT_AUTO_SCREEN_SCALE_FACTOR "1" \
      --set QT_IM_MODULE "fcitx5" \
      --set GTK_IM_MODULE "fcitx5"
      
    runHook postInstall
  '';
  desktopItems = [
    makeDesktopItem {
      name = "dingtalk";
      desktopName = "Dingtalk";
      genericName = "dingtalk";
      categories = [ "Chat" ];
      exec = "dingtalk %u";
      icon = "dingtalk";
      keywords = [ "dingtalk" ];
      mimeTypes = [ "x-scheme-handler/dingtalk" ];
      extraConfig = {
        "Name[zh_CN]" = "钉钉";
        "Name[zh_TW]" = "釘釘";
      };
    }
  ];
  meta = {
    maintainers = with lib.maintainers; [ "cinqwqeggs" ];
    description = "Enterprise communication and collaboration platform developed by Alibaba Group";
    homepage = "https://www.dingtalk.com/";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "dingtalk";
  };
}
