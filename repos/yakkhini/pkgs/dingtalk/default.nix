{
  fetchurl,
  stdenv,
  callPackage,
  autoPatchelfHook,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  dpkg,
  # DingTalk dependencies
  alsa-lib,
  apr,
  aprutil,
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
  opencv,
  openldap,
  pango,
  pcre2,
  pipewire,
  qt5,
  rtmpdump,
  udev,
  util-linux,
  libICE,
  libSM,
  libX11,
  libxcb,
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
  xcbutilimage,
  xcbutilkeysyms,
  xcbutilrenderutil,
  xcbutilwm,
}:
################################################################################
# Mostly based on dingtalk-bin package from AUR:
# https://aur.archlinux.org/packages/dingtalk-bin
################################################################################
let
  pname = "dingtalk";
  version = "9.0.0.261105002";

  src = fetchurl {
    url = "https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release/com.alibabainc.dingtalk_${version}_amd64.deb";
    hash = "sha256-mg6eWTA/zl2Ggt4Q7PyCHHpgP4iSQjYpFEn+LAiQ0fU=";
  };

  dingtalk-wayland-screenshare = callPackage ./wayland-screenshare.nix {};

  libraries = [
    alsa-lib
    apr
    aprutil
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
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      autoPatchelfHook
      qt5.wrapQtAppsHook
      copyDesktopItems
      dpkg
    ];
    buildInputs = libraries;

    # We will append QT wrapper args to our own wrapper
    dontWrapQtApps = true;

    unpackPhase = ''
      runHook preUnpack

      dpkg -x $src .

      mv opt/apps/com.alibabainc.dingtalk/files/version version
      mv opt/apps/com.alibabainc.dingtalk/files/*-Release.* release

      # Cleanup
      # Keep the bundled OpenSSL 1.1 libraries: DingTalk still requires their ABI,
      # which is no longer provided by nixpkgs.
      rm -f release/{dingtalk_crash_report,dingtalk_updater,libapr*,libcurl.so.*}
      rm -f release/{libdouble-conversion.so.*,libgbm.*,libgdk*}
      rm -f release/{libgtk*,libharfbuzz*,libicu*,libidn2*,libjpeg*,libm.so.*,libnghttp2*}
      rm -f release/{libpcre2*,libpng*,libpsl*,libQt5*,libssh2*}
      rm -f release/{libstdc++*,libunistring*,libxcb*,libz*}
      rm -rf release/{imageformats,platform*,xcbglintegrations}
      rm -rf release/Resources/qss/mac

      runHook postUnpack
    '';

    postPatch = ''
      # doctor uses Qt and imports no GTK2 symbols. Drop its unused
      # DT_NEEDED entry so it does not pull in the retired GTK2 stack.
      patchelf --remove-needed libgtk-x11-2.0.so.0 release/doctor
    '';

    installPhase = ''
      runHook preInstall

      install -Dm644 version $out/version

      # Move libraries
      # DingTalk relies on (some of) the exact libraries it ships with
      mv release $out/lib

      # Entrypoint
      mkdir -p $out/bin
      cat > $out/bin/dingtalk <<EOF
      #!/usr/bin/env bash
      if [[ \''${XMODIFIERS} =~ fcitx ]]; then
        export QT_IM_MODULE=fcitx
        export GTK_IM_MODULE=fcitx
      elif [[ \''${XMODIFIERS} =~ ibus ]]; then
        export QT_IM_MODULE=ibus
        export GTK_IM_MODULE=ibus
        export IBUS_USE_PORTAL=1
      fi

      exec $out/lib/com.alibabainc.dingtalk
      EOF
      chmod +x $out/bin/dingtalk

      wrapProgram $out/bin/dingtalk \
        "''${qtWrapperArgs[@]}" \
        --chdir $out/lib \
        --unset WAYLAND_DISPLAY \
        --set QT_QPA_PLATFORM "xcb" \
        --set QT_AUTO_SCREEN_SCALE_FACTOR 1 \
        --prefix LD_PRELOAD : "${dingtalk-wayland-screenshare}/lib/libdingtalkhook.so" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}"

      # App Menu
      install -Dm644 $out/lib/Resources/image/common/about/logo.png $out/share/pixmaps/dingtalk.png

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "dingtalk";
        desktopName = "Dingtalk";
        genericName = "dingtalk";
        categories = ["Chat"];
        exec = "dingtalk %u";
        icon = "dingtalk";
        keywords = ["dingtalk"];
        mimeTypes = ["x-scheme-handler/dingtalk"];
        extraConfig = {
          "Name[zh_CN]" = "钉钉";
          "Name[zh_TW]" = "釘釘";
        };
      })
    ];

    passthru = {inherit dingtalk-wayland-screenshare;};

    meta = {
      maintainers = with lib.maintainers; [xddxdd];
      description = "Enterprise communication and collaboration platform developed by Alibaba Group";
      homepage = "https://www.dingtalk.com/";
      platforms = ["x86_64-linux"];
      license = lib.licenses.unfreeRedistributable;
      knownVulnerabilities = [
        "Bundles OpenSSL 1.1, which reached end of life on 2023-09-11 and no longer receives security updates."
      ];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "dingtalk";
    };
  }
