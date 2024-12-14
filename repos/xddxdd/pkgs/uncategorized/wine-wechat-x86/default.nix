{
  sources,
  stdenv,
  lib,
  p7zip,
  wine,
  winetricks,
  writeShellScript,
  makeDesktopItem,
  copyDesktopItems,
}:
################################################################################
# Some assets are copied from AUR:
# https://aur.archlinux.org/packages/deepin-wine-wechat
#
# Known issues:
# - In-app browser doesn't work.
################################################################################
let
  wechatWine = wine.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./wine-wechat.patch ];
  });

  wechatFiles = stdenv.mkDerivation {
    pname = "wechat-x86";
    inherit (sources.wine-wechat-x86) version src;

    nativeBuildInputs = [ p7zip ];

    unpackPhase = ''
      ls -alh $src
      7z x $src
      rm -rf \$*
    '';

    installPhase = ''
      mkdir $out
      cp -r * $out/
    '';
  };

  startWechat = writeShellScript "wine-wechat-x86" ''
    export WINEARCH="win32"
    export WINEPREFIX="$HOME/.local/share/wine-wechat-x86"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export PATH="${wechatWine}/bin:$PATH"
    export LANG="zh_CN.UTF-8"

    winetricks() {
      grep $1 $WINEPREFIX/winetricks.log >/dev/null || ${winetricks}/bin/winetricks $1
    }

    ${wechatWine}/bin/wineboot
    winetricks msls31
    winetricks riched20

    ${wechatWine}/bin/wine regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine ${wechatFiles}/WeChat.exe
    ${wechatWine}/bin/wineserver -k
  '';

  startWinecfg = writeShellScript "wine-wechat-x86-cfg" ''
    export WINEARCH="win32"
    export WINEPREFIX="$HOME/.local/share/wine-wechat-x86"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export PATH="${wechatWine}/bin:$PATH"
    export LANG="zh_CN.UTF-8"

    winetricks() {
      grep $1 $WINEPREFIX/winetricks.log >/dev/null || ${winetricks}/bin/winetricks $1
    }

    ${wechatWine}/bin/wineboot
    winetricks msls31
    winetricks riched20

    ${wechatWine}/bin/wine regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine winecfg.exe
    ${wechatWine}/bin/wineserver -k
  '';
in
stdenv.mkDerivation {
  pname = "wine-wechat-x86";
  inherit (sources.wine-wechat-x86) version;
  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    install -Dm755 ${startWechat} $out/bin/wine-wechat-x86
    install -Dm755 ${startWinecfg} $out/bin/wine-wechat-x86-cfg
    install -Dm644 ${./wine-wechat.png} $out/share/pixmaps/wine-wechat-x86.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wine-wechat-x86";
      exec = "wine-wechat-x86";
      icon = "wine-wechat-x86";
      desktopName = "Wine WeChat (x86)";
      comment = "Run WeChat (x86) with Wine";
      startupWMClass = "wechat.exe";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      keywords = [
        "wx"
        "wechat"
        "weixin"
      ];
      extraConfig = {
        "Name[zh_CN]" = "Wine 微信（x86）";
        "Name[zh_TW]" = "Wine 微信（x86）";
        "Comment[zh_CN]" = "使用 Wine 运行微信（x86）";
        "Comment[zh_TW]" = "使用 Wine 运行微信（x86）";
      };
    })
    (makeDesktopItem {
      name = "wine-wechat-x86-cfg";
      exec = "wine-wechat-x86-cfg";
      icon = "wine-wechat-x86";
      desktopName = "Wine WeChat (x86) config";
      comment = "Run winecfg for Wine WeChat (x86)";
      startupNotify = true;
      categories = [ "Settings" ];
      keywords = [
        "wx"
        "wechat"
        "weixin"
      ];
      extraConfig = {
        "Name[zh_CN]" = "Wine 微信（x86）配置";
        "Name[zh_TW]" = "Wine 微信（x86）配置";
        "Comment[zh_CN]" = "为 Wine 微信（x86）运行 winecfg";
        "Comment[zh_TW]" = "为 Wine 微信（x86）运行 winecfg";
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Wine WeChat x86 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat)";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "wine-wechat-x86";
  };
}
