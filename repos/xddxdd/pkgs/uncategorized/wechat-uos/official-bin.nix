{
  sources,
  stdenv,
  buildFHSUserEnvBubblewrap,
  autoPatchelfHook,
  writeShellScript,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  # WeChat dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libpulseaudio,
  mesa_drivers,
  nspr,
  nss,
  openssl_1_1,
  pango,
  pciutils,
  scrot,
  udev,
  xorg,
  ...
} @ args:
################################################################################
# Mostly based on wechat-uos package from AUR:
# https://aur.archlinux.org/packages/wechat-uos
################################################################################
let
  libraries = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libpulseaudio
    mesa_drivers
    nspr
    nss
    openssl_1_1
    pango
    pciutils
    udev
    xorg.libX11
    xorg.libxcb
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

  license = stdenv.mkDerivation {
    pname = "wechat-uos-license";
    version = "0.0.1";
    src = ./license.tar.gz;

    installPhase = ''
      mkdir -p $out
      cp -r etc var $out/
    '';
  };

  resource = stdenv.mkDerivation rec {
    pname = "wechat-uos-bin";
    inherit (sources.wechat-uos) version src;

    nativeBuildInputs = [autoPatchelfHook];

    buildInputs = libraries;

    unpackPhase = ''
      ar x $src
    '';

    installPhase = ''
      mkdir -p $out
      tar xf data.tar.xz -C $out
      mv $out/usr/* $out/
      chmod 0644 $out/lib/license/libuosdevicea.so
      rm -rf $out/usr

      # use system scrot
      pushd $out/opt/apps/com.tencent.weixin/files/weixin/resources/app/packages/main/dist/
      sed -i 's|__dirname,"bin","scrot"|"${scrot}/bin/"|g' index.js
      popd
    '';
  };

  startScript = writeShellScript "wechat-uos" ''
    wechat_pid=`pidof wechat-uos`
    if test $wechat_pid; then
        kill -9 $wechat_pid
    fi

    ${resource}/opt/apps/com.tencent.weixin/files/weixin/weixin
  '';

  fhs = buildFHSUserEnvBubblewrap {
    name = "wechat-uos";
    targetPkgs = pkgs:
      [
        license
        resource
      ]
      ++ libraries;
    runScript = startScript;
    unsharePid = false;
  };
in
  stdenv.mkDerivation {
    pname = "wechat-uos-bin";
    inherit (sources.wechat-uos) version;
    dontUnpack = true;

    nativeBuildInputs = [copyDesktopItems];

    postPhase = ''
      mkdir -p $out/bin $out/share
      ln -s ${fhs}/bin/wechat-uos $out/bin/wechat-uos
      ln -s ${resource}/share/icons $out/share/icons
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "wechat-uos";
        desktopName = "WeChat";
        exec = "wechat-uos %U";
        terminal = false;
        icon = "weixin";
        startupWMClass = "weixin";
        comment = "WeChat Desktop Edition";
        categories = ["Utility"];
        keywords = ["wechat" "weixin" "wechat-uos"];
        extraConfig = {
          "Name[zh_CN]" = "微信";
          "Name[zh_TW]" = "微信";
          "Comment[zh_CN]" = "微信桌面版";
          "Comment[zh_TW]" = "微信桌面版";
        };
      })
    ];

    meta = with lib; {
      description = "WeChat desktop (Official binary) (Packaging script adapted from https://aur.archlinux.org/packages/wechat-uos)";
      homepage = "https://weixin.qq.com/";
      platforms = ["x86_64-linux"];
      license = licenses.unfreeRedistributable;
    };
  }
