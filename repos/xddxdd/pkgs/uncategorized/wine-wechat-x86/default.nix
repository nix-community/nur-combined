{
  sources,
  stdenv,
  fetchurl,
  lib,
  p7zip,
  wine,
  winetricks,
  writeShellScript,
  makeDesktopItem,
  copyDesktopItems,
  ...
}:
################################################################################
# Some assets are copied from AUR:
# https://aur.archlinux.org/packages/deepin-wine-wechat
#
# Known issues:
# - In-app browser doesn't work.
################################################################################
let
  wineGecko = stdenv.mkDerivation rec {
    pname = "wine-gecko";
    version = "2.47.4";
    src = fetchurl {
      url = "http://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.tar.xz";
      sha256 = "1dmg221nxmgyhz7clwlnvwrx1wi630z62y4azwgf40l6jif8vz1c";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      tar xf $src -C $out
    '';
  };

  wechatWine = wine.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./wine-wechat.patch ];

    postInstall =
      (old.postInstall or "")
      + ''
        rm -rf $out/share/wine/gecko
        ln -sf ${wineGecko} $out/share/wine/gecko
      '';
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
    mkdir -p $out/bin $out/share/pixmaps
    ln -s ${startWechat} $out/bin/wine-wechat-x86
    ln -s ${startWinecfg} $out/bin/wine-wechat-x86-cfg
    cp -r ${./wine-wechat.png} $out/share/pixmaps/wine-wechat-x86.png
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

  meta = with lib; {
    description = "Wine WeChat x86 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat)";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
