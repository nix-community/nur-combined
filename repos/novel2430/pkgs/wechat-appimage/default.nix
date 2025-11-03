{ stdenv
, lib
, makeWrapper
, appimageTools
, fetchurl
, copyDesktopItems
, makeDesktopItem 
, writeShellScript
, buildFHSEnvBubblewrap
, xhost
, xdg-user-dirs
}:
let
  pkgname = "wechat-appimage";
  pkgver = "4.0.13";
  wechat-src = appimageTools.wrapType2 {
    pname = "${pkgname}";
    version = "${pkgver}";

    src = fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-+r5Ebu40GVGG2m2lmCFQ/JkiDsN/u7XEtnLrB98602w=";
    };
  };
  appimageContent = appimageTools.extractType1 {
    pname = "${pkgname}";
    version = "${pkgver}";

    src = fetchurl {
      url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
      hash = "sha256-+r5Ebu40GVGG2m2lmCFQ/JkiDsN/u7XEtnLrB98602w=";
    };

  };
  xdg-dir = "${xdg-user-dirs}/bin";
  startScript = writeShellScript "wechat-start" ''
    export QT_QPA_PLATFORM=xcb
    if [[ ''${XMODIFIERS} =~ fcitx ]]; then
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
    elif [[ ''${XMODIFIERS} =~ ibus ]]; then
      export QT_IM_MODULE=ibus
      export GTK_IM_MODULE=ibus
      export IBUS_USE_PORTAL=1
    fi
    exec ${wechat-src}/bin/${pkgname}
  '';

  fhs = buildFHSEnvBubblewrap {
    name = "wechat-fhs";

    targetPkgs = 
      pkgs: [
        wechat-src
      ];

    runScript = startScript;

    extraPreBwrapCmds = ''
      function detectXauth() {
        if [ ! ''${XAUTHORITY} ]; then
          echo '[Warn] No ''${XAUTHORITY} detected! Do you have any X server running?'
          export XAUTHORITYpath="/$(uuidgen)/$(uuidgen)"
          ${xhost}/bin/xhost +
        else
          export XAUTHORITYpath="''${XAUTHORITY}"
        fi
        if [[ ! ''${DISPLAY} ]]; then
          echo '[Warn] No ''${DISPLAY} detected! Do you have any X server running?'
        fi
      }
      # Data folder setup
      # If user has declared a custom data dir, no need to query xdg for documents dir, but always resolve that to absolute path
      if [[ "''${WECHAT_DATA_DIR}" ]]; then
          WECHAT_DATA_DIR=$(readlink -f -- "''${WECHAT_DATA_DIR}")
      else
          XDG_DOCUMENTS_DIR="''${XDG_DOCUMENTS_DIR:-$(${xdg-dir}/xdg-user-dir DOCUMENTS)}"
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
      detectXauth

    '';

    extraBwrapArgs = [
      "--tmpfs /home"
      "--tmpfs /root"
      "--bind \${WECHAT_HOME_DIR} \${HOME}"
      "--bind \${WECHAT_FILES_DIR} \${WECHAT_FILES_DIR}"
      "--chdir $HOME"
      "--setenv QT_QPA_PLATFORM xcb"
      # "--setenv QT_AUTO_SCREEN_SCALE_FACTOR 1"

      "--ro-bind-try \${XAUTHORITYpath} \${XAUTHORITYpath}"

      "--ro-bind-try \${HOME}/.fontconfig{,}"
      "--ro-bind-try \${HOME}/.fonts{,}"
      "--ro-bind-try \${HOME}/.config/fontconfig{,}"
      "--ro-bind-try \${HOME}/.local/share/fonts{,}"
      "--ro-bind-try \${HOME}/.icons{,}"
      "--ro-bind-try \${HOME}/.local/share/.icons{,}"
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
  pname = "${pkgname}";
  version = "${pkgver}";
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall
    for res in 16 32 48 64 128 256; do
      for name in {${pkgname},wechat,weixin,com.tencent.WeChat,com.tencent.wechat}; do
        install -Dm644 \
            ${appimageContent}/wechat.png \
            $out/share/icons/hicolor/''${res}x''${res}/apps/''${name}.png
      done
    done
    makeWrapper ${fhs}/bin/wechat-fhs $out/bin/${pkgname}
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "${pkgname}";
      desktopName = "WeChat Appimage";
      exec = "${pkgname} %U";
      terminal = false;
      icon = "${pkgname}";
      comment = "WeChat Appimage";
      categories = [ "Utility" "Network" "InstantMessaging" "Chat" ];
      keywords = [
        "wechat"
        "weixin"
        "${pkgname}"
      ];
      extraConfig = {
        "Name[zh_CN]" = "微信 Appimage";
        "Name[zh_TW]" = "微信 Appimage";
        "Comment[zh_CN]" = "微信桌面版 Appimage";
        "Comment[zh_TW]" = "微信桌面版 Appimage";
      };
    })
  ];
  meta = with lib; {
    description = ''
      WeChat in Appimage
    '';
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
