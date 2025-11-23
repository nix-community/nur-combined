{ stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  dpkg,
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
  pcre2,
  qt5,
  rtmpdump,
  udev,
  util-linux,
  xorg,
}:

let
  libraries = [
    alsa-lib apr aprutil at-spi2-atk at-spi2-core cairo cups curl dbus e2fsprogs
    fontconfig freetype fribidi gdk-pixbuf glib gnome2.gtkglext gnutls graphite2
    gtk3 harfbuzz icu63 krb5 libdrm libgcrypt libGLU libglvnd libidn2 libinput
    libjpeg libpng libpsl libpulseaudio libssh2 libthai libxcrypt-legacy libxkbcommon
    mesa mtdev nghttp2 nspr nss openldap openssl_1_1 pango pcre2
    qt5.qtbase qt5.qtmultimedia qt5.qtsvg qt5.qtx11extras rtmpdump udev util-linux
    xorg.libICE xorg.libSM xorg.libX11 xorg.libxcb xorg.libXcomposite xorg.libXcursor
    xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXi xorg.libXinerama xorg.libXmu
    xorg.libXrandr xorg.libXrender xorg.libXScrnSaver xorg.libXt xorg.libXtst
    xorg.xcbutilimage xorg.xcbutilkeysyms xorg.xcbutilrenderutil xorg.xcbutilwm
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
    qt5.wrapQtAppsHook
    copyDesktopItems
    dpkg
  ];

  buildInputs = libraries;
  dontWrapQtApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg -x $src .
    mv opt/apps/com.alibainc.dingtalk/files/version version || true
    mv opt/apps/com.alibainc.dingtalk/files/*-Release.* release || true
    rm -f release/{*.a,*.la,*.prl,dingtalk_crash_report,dingtalk_updater,libapr*,libcrypto.so.*,libcurl.so.*} || true
    rm -f release/{libdouble-conversion.so.*,libEGL*,libgbm.*,libGLES*} || true
    rm -rf release/{engines-1_1,imageformats,platform*,swiftshader,xcbglintegrations} || true
    rm -rf release/Resources/{i18n/tool/*.exe,qss/mac} || true
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 version $out/version
    mv release $out/lib
    mkdir -p $out/bin
    cat > $out/bin/dingtalk <<EOF
#!/usr/bin/env bash
export XDG_DATA_DIRS="\$XDG_DATA_DIRS:/run/current-system/sw/share"
if [[ "\$XMODIFIERS" =~ fcitx ]]; then
  export QT_IM_MODULE=fcitx
  export GTK_IM_MODULE=fcitx
elif [[ "\$XMODIFIERS" =~ ibus ]]; then
  export QT_IM_MODULE=ibus
  export GTK_IM_MODULE=ibus
  export IBUS_USE_PORTAL=1
fi
exec "$out/lib/com.alibabainc.dingtalk"
EOF
    chmod +x $out/bin/dingtalk
    wrapProgram $out/bin/dingtalk \
      "''${qtWrapperArgs[@]}" \
      --chdir $out/lib \
      --unset WAYLAND_DISPLAY \
      --set QT_QPA_PLATFORM "xcb" \
      --set QT_AUTO_SCREEN_SCALE_FACTOR 1 \
      --prefix LD_PRELOAD : "$out/lib/libcef.so" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
      --set XDG_DATA_DIRS "/run/current-system/sw/share"
    install -Dm644 $out/lib/Resources/image/common/about/logo.png $out/share/pixmaps/dingtalk.png || true
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
