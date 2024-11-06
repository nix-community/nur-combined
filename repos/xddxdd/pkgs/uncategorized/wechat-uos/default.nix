{
  sources,
  stdenv,
  buildFHSUserEnvBubblewrap,
  writeShellScript,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  writeShellScriptBin,
  callPackage,
  dpkg,
  # Options
  enableSandbox ? true, # There are previous reports of WeChat scanning user files without authorization
  # WeChat dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  atkmm,
  bzip2,
  cairo,
  cups,
  dbus,
  expat,
  ffmpeg,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libexif,
  libGL,
  libjack2,
  libnotify,
  libuuid,
  libva,
  libxkbcommon,
  libxml2,
  mesa,
  nspr,
  nss,
  pango,
  pulseaudio,
  qt6,
  systemd,
  vulkan-loader,
  wayland,
  xorg,
  zlib,
}:
################################################################################
# Mostly based on wechat-uos-bwrap package from AUR:
# https://aur.archlinux.org/packages/wechat-uos-bwrap
################################################################################
let
  # zerocallusedregs hardening breaks WeChat
  glibcWithoutHardening = stdenv.cc.libc.overrideAttrs (old: {
    hardeningDisable = (old.hardeningDisable or [ ]) ++ [ "zerocallusedregs" ];
  });

  libuosdevicea-stub = callPackage ./libuosdevicea-stub.nix { };

  libraries = [
    # Make sure our glibc without hardening gets picked up first
    (lib.hiPrio glibcWithoutHardening)

    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    atkmm
    bzip2
    cairo
    cups
    dbus
    expat
    ffmpeg
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libexif
    libGL
    libjack2
    libnotify
    libuuid
    libva
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    pango
    pulseaudio
    qt6.qt5compat
    stdenv.cc.cc
    stdenv.cc.libc
    systemd
    vulkan-loader
    wayland
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXft
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXt
    xorg.libXtst
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
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

  resource = stdenv.mkDerivation {
    pname = "wechat-uos";
    inherit (sources.wechat-uos) version src;

    nativeBuildInputs = [ dpkg ];

    installPhase = ''
      dpkg -x $src $out
      rm -f $out/opt/apps/com.tencent.wechat/files/libuosdevicea.so
      install -Dm755 ${libuosdevicea-stub}/lib/libuosdevicea.so $out/opt/apps/com.tencent.wechat/files/libuosdevicea.so
      install -Dm755 ${libuosdevicea-stub}/lib/libuosdevicea.so $out/lib/license/libuosdevicea.so
    '';
  };

  # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/open.sh?h=wechat-uos-bwrap
  fake-dde-file-manager = writeShellScriptBin "dde-file-manager" ''
    if command -v dolphin &> /dev/null; then
      dolphin --select "$2"
    elif command -v nautilus &> /dev/null; then
      nautilus $(dirname "$2")
    else
      xdg-open $(dirname "$2")
    fi
  '';

  # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/wechat.sh?h=wechat-uos-bwrap
  startScript = writeShellScript "wechat" ''
    if [[ ''${XMODIFIERS} =~ fcitx ]]; then
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
    elif [[ ''${XMODIFIERS} =~ ibus ]]; then
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export IBUS_USE_PORTAL=1
    fi

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib
    exec ${resource}/opt/apps/com.tencent.wechat/files/wechat
  '';

  fhs = buildFHSUserEnvBubblewrap {
    name = "wechat-uos";
    targetPkgs =
      _pkgs:
      [
        license
        resource
        fake-dde-file-manager
      ]
      ++ libraries;
    runScript = startScript;

    # Add these root paths to FHS sandbox to prevent WeChat from accessing them by default
    # Adapted from https://aur.archlinux.org/cgit/aur.git/tree/wechat-universal.sh?h=wechat-universal-bwrap
    extraPreBwrapCmds = ''
      # Data folder setup
      # If user has declared a custom data dir, no need to query xdg for documents dir, but always resolve that to absolute path
      if [[ "''${WECHAT_DATA_DIR}" ]]; then
          WECHAT_DATA_DIR=$(readlink -f -- "''${WECHAT_DATA_DIR}")
      else
          XDG_DOCUMENTS_DIR="''${XDG_DOCUMENTS_DIR:-$(xdg-user-dir DOCUMENTS)}"
          if [[ -z "''${XDG_DOCUMENTS_DIR}" ]]; then
              echo 'Error: Failed to get XDG_DOCUMENTS_DIR, refuse to continue'
              exit 1
          fi
          WECHAT_DATA_DIR="''${XDG_DOCUMENTS_DIR}/WeChat_Data"
      fi
      WECHAT_FILES_DIR="''${WECHAT_DATA_DIR}/xwechat_files"
      WECHAT_HOME_DIR="''${WECHAT_DATA_DIR}/home"
      mkdir -p "''${WECHAT_FILES_DIR}"
      mkdir -p "''${WECHAT_HOME_DIR}"
    '';
    extraBwrapArgs =
      lib.optionals enableSandbox [
        "--tmpfs /home"
        "--tmpfs /root"
        "--bind \${WECHAT_HOME_DIR} \${HOME}"
        "--bind \${WECHAT_FILES_DIR} \${WECHAT_FILES_DIR}"
        "--ro-bind ${license}/var /var"
        "--chdir $HOME"
        "--setenv QT_QPA_PLATFORM xcb"
        "--setenv QT_AUTO_SCREEN_SCALE_FACTOR 1"
      ]
      ++ [
        "--tmpfs ${glibcWithoutHardening}/etc"
      ];

    unshareUser = true;
    unshareIpc = true;
    unsharePid = true;
    unshareNet = false;
    unshareUts = true;
    unshareCgroup = true;
    privateTmp = true;
  };
in
stdenv.mkDerivation {
  pname = "wechat-uos";
  inherit (sources.wechat-uos) version;
  dontUnpack = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  postInstall = ''
    mkdir -p $out/bin $out/share
    ln -s ${fhs}/bin/wechat-uos $out/bin/wechat-uos
    ln -s ${resource}/opt/apps/com.tencent.wechat/entries/icons $out/share/icons
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wechat-uos";
      desktopName = "WeChat";
      exec = "wechat-uos %U";
      terminal = false;
      icon = "com.tencent.wechat";
      startupWMClass = "weixin";
      comment = "WeChat Desktop Edition";
      categories = [ "Utility" ];
      keywords = [
        "wechat"
        "weixin"
        "wechat-uos"
      ];
      extraConfig = {
        "Name[zh_CN]" = "微信";
        "Name[zh_TW]" = "微信";
        "Comment[zh_CN]" = "微信桌面版";
        "Comment[zh_TW]" = "微信桌面版";
      };
    })
  ];

  meta = {
    mainProgram = "wechat-uos";
    maintainers = with lib.maintainers; [ xddxdd ];
    description =
      if enableSandbox then
        "WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap)"
      else
        "WeChat desktop without sandbox (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap)";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
  };
}
