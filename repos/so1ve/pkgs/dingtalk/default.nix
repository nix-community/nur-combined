{
  alsa-lib,
  apr,
  aprutil,
  at-spi2-atk,
  at-spi2-core,
  autoPatchelfHook,
  callPackage,
  cairo,
  copyDesktopItems,
  cups,
  curl,
  dbus,
  dpkg,
  e2fsprogs,
  fontconfig,
  freetype,
  fribidi,
  gdk-pixbuf,
  glib,
  gtk3,
  gnutls,
  graphite2,
  harfbuzz,
  icu63,
  krb5,
  lib,
  libGLU,
  libICE,
  libSM,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libXmu,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libXt,
  libXtst,
  libxcb,
  libdrm,
  libgcrypt,
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
  makeDesktopItem,
  makeWrapper,
  mesa,
  mtdev,
  nghttp2,
  nspr,
  nss,
  opencv,
  openldap,
  pango,
  pcre2,
  pipewire,
  prelink,
  qt5,
  rtmpdump,
  source ? callPackage ./source.nix { },
  stdenv,
  udev,
  util-linux,
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
}:

let
  screenshareHook = lib.optionalString stdenv.isx86_64 (
    "${callPackage ./wayland-screenshare.nix { }}/lib/libdingtalkhook.so"
  );

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
    opencv
    openldap
    pango
    pcre2
    pipewire
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qtsvg
    qt5.qtx11extras
    rtmpdump
    udev
    util-linux
    libICE
    libSM
    libX11
    libxcb
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXinerama
    libXmu
    libXrandr
    libXrender
    libXScrnSaver
    libXt
    libXtst
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dingtalk";
  inherit (source) version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    dpkg
    makeWrapper
    prelink
    qt5.wrapQtAppsHook
  ];

  buildInputs = libraries;

  # The Qt hook provides arguments for the wrapper below.
  dontWrapQtApps = true;

  unpackPhase = ''
    runHook preUnpack

    dpkg -x "$src" .
    mv opt/apps/com.alibabainc.dingtalk/files/version version
    mv opt/apps/com.alibabainc.dingtalk/files/*-Release.* release

    # Keep the bundled OpenSSL 1.1 libraries: DingTalk still requires their ABI.
    rm -f release/{*.a,*.la,*.prl,dingtalk_crash_report,dingtalk_updater,libapr*,libcurl.so.*}
    rm -f release/{libdouble-conversion.so.*,libEGL*,libfontconfig*,libfreetype*,libfribidi*,libgbm.*,libgdk-x11-2.0.so.*,libGLES*}
    rm -f release/{libgtk-x11-2.0.so.*,libharfbuzz*,libicu*,libidn2*,libjpeg*,libm.so.*,libnghttp2*}
    rm -f release/{libpango-1.0.*,libpangocairo-1.0.*,libpangoft2-1.0.*,libpcre2*,libpng*,libpsl*,libQt5*,libssh2*}
    rm -f release/{libstdc++.so.6,libstdc++*,libunistring*,libvk*,libvulkan*,libxcb*,libz*}
    rm -f release/{doctor,libgdkglext-x11*,libgtkglext-x11*}
    rm -rf release/{engines-1_1,imageformats,platform*,swiftshader,xcbglintegrations}
    rm -rf release/Resources/{i18n/tool/*.exe,qss/mac}

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm444 version "$out/version"
    mv release "$out/lib"

    mkdir -p "$out/bin"
    cat > "$out/bin/dingtalk" <<EOF
    #!/usr/bin/env bash
    if [[ \''${XMODIFIERS} =~ fcitx ]]; then
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
    elif [[ \''${XMODIFIERS} =~ ibus ]]; then
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export IBUS_USE_PORTAL=1
    fi

    exec "$out/lib/com.alibabainc.dingtalk" "\$@"
    EOF
    chmod +x "$out/bin/dingtalk"

    wrapProgram "$out/bin/dingtalk" \
      "''${qtWrapperArgs[@]}" \
      --chdir "$out/lib" \
      --unset WAYLAND_DISPLAY \
      --set QT_QPA_PLATFORM xcb \
      --set QT_AUTO_SCREEN_SCALE_FACTOR 1 \
      ${lib.optionalString stdenv.isx86_64 "--prefix LD_PRELOAD : ${screenshareHook}"} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

    install -Dm444 "$out/lib/Resources/image/common/about/logo.png" \
      "$out/share/pixmaps/dingtalk.png"

    runHook postInstall
  '';

  postFixup = ''
    execstack -c "$out/lib/dingtalk_dll.so"
    execstack -c "$out/lib/libconference_new.so"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "dingtalk";
      desktopName = "DingTalk";
      genericName = "DingTalk";
      categories = [ "Chat" ];
      exec = "dingtalk %u";
      icon = "dingtalk";
      keywords = [ "dingtalk" ];
      mimeTypes = [ "x-scheme-handler/dingtalk" ];
      extraConfig = {
        "Name[zh_CN]" = "钉钉";
        "Name[zh_TW]" = "釘釘";
      };
    })
  ];

  passthru = lib.optionalAttrs stdenv.isx86_64 {
    dingtalk-wayland-screenshare = callPackage ./wayland-screenshare.nix { };
  };

  meta = {
    description = "DingTalk desktop client";
    homepage = "https://www.dingtalk.com/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "dingtalk";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
