{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "wechat";
  version = "4.1.13";

  src = fetchurl {
    urls = [
      "https://dldir1.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
      "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
    ];
    hash = "sha256-ay4g5wAGNy6N37rkDqhkVkUgyHsH0BYLYA7JP3j9XMI=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/wechat/wechat
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  # WeChat 4.1.13 supports native Wayland, but its bundled Fcitx plugin
  # still uses the legacy X11 input context. Explicitly select its bundled
  # text-input-v3 plugin: Qt 5's default Wayland input context uses v2,
  # which compositors such as Niri do not support.
  # Put this in the shared launcher for both desktop and terminal starts.
  profile = ''
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      export QT_QPA_PLATFORM=wayland
      export QT_IM_MODULE=text-input-unstable-v3
      unset QT_IM_MODULES
    else
      export QT_QPA_PLATFORM=xcb
      export QT_IM_MODULE="''${QT_IM_MODULE:-fcitx}"
      export GTK_IM_MODULE="''${GTK_IM_MODULE:-fcitx}"
      export XMODIFIERS="''${XMODIFIERS:-@im=fcitx}"
    fi
  '';

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/wechat.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-fail 'Exec=AppRun %U' 'Exec=wechat %U'
  '';

  meta = {
    description = "WeChat - Messaging and calling app";
    homepage = "https://www.wechat.com/";
    downloadPage = "https://linux.weixin.qq.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "wechat";
    platforms = [ "x86_64-linux" ];
  };
}
