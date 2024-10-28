{
  sources,
  stdenv,
  buildFHSUserEnvBubblewrap,
  autoPatchelfHook,
  writeShellScript,
  lib,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  writeShellScriptBin,
  callPackage,
  # Options
  enableSandbox ? true, # There are previous reports of WeChat scanning user files without authorization
  # WeChat dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  gtk3,
  gtk4,
  libglvnd,
  libpulseaudio,
  libva,
  mesa,
  nspr,
  nss,
  pango,
  pciutils,
  qt6,
  udev,
  xorg,
  wayland,
  ...
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
    cairo
    gtk3
    gtk4
    libglvnd
    libpulseaudio
    libva
    mesa
    nspr
    nss
    pango
    pciutils
    qt6.qt5compat
    udev
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXrandr
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    wayland
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

    nativeBuildInputs = [
      autoPatchelfHook
      qt6.wrapQtAppsHook
    ];

    autoPatchelfFlags = [ "--keep-libc" ];

    buildInputs = libraries;

    unpackPhase = ''
      ar x $src
    '';

    installPhase = ''
      mkdir -p $out
      tar xf data.tar.xz -C $out

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

    export LD_PRELOAD=${glibcWithoutHardening}/lib/libc.so.6:$LD_PRELOAD
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

    makeWrapper ${fhs}/bin/wechat-uos $out/bin/wechat-uos \
      --run "mkdir -p \$HOME/.local/share/wechat-uos"

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

  meta = with lib; {
    mainProgram = "wechat-uos";
    maintainers = with lib.maintainers; [ xddxdd ];
    description =
      if enableSandbox then
        "WeChat desktop with sandbox enabled ($HOME/Documents/WeChat_Data) (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap)"
      else
        "WeChat desktop without sandbox (Adapted from https://aur.archlinux.org/packages/wechat-uos-bwrap)";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
