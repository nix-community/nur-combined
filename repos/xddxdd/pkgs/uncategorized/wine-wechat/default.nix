{
  sources,
  stdenv,
  fetchurl,
  lib,
  p7zip,
  wine64,
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
      url = "http://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86_64.tar.xz";
      sha256 = "0518m084f9bdl836gs3d8qm8jx65j2y1w35zi9x8s1bxadzgr27x";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      tar xf $src -C $out
    '';
  };

  wechatWine = wine64.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./wine-wechat.patch ];

    postInstall =
      (old.postInstall or "")
      + ''
        rm -rf $out/share/wine/gecko
        ln -sf ${wineGecko} $out/share/wine/gecko
      '';
  });

  wechatFiles = stdenv.mkDerivation {
    pname = "wechat";
    inherit (sources.wine-wechat-x64) version src;

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

  startWechat = writeShellScript "wine-wechat" ''
    export WINE="${wechatWine}/bin/wine64"
    export WINEARCH="win64"
    export WINEPREFIX="$HOME/.local/share/wine-wechat"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export PATH="${wechatWine}/bin:$PATH"
    export LANG="zh_CN.UTF-8"

    winetricks() {
      grep $1 $WINEPREFIX/winetricks.log >/dev/null || ${winetricks}/bin/winetricks $1
    }

    ${wechatWine}/bin/wineboot
    winetricks msls31
    winetricks riched20

    ${wechatWine}/bin/wine64 regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine64 ${wechatFiles}/WeChat.exe
    ${wechatWine}/bin/wineserver -k
  '';

  startWinecfg = writeShellScript "wine-wechat-cfg" ''
    export WINE="${wechatWine}/bin/wine64"
    export WINEARCH="win64"
    export WINEPREFIX="$HOME/.local/share/wine-wechat"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export PATH="${wechatWine}/bin:$PATH"
    export LANG="zh_CN.UTF-8"

    winetricks() {
      grep $1 $WINEPREFIX/winetricks.log >/dev/null || ${winetricks}/bin/winetricks $1
    }

    ${wechatWine}/bin/wineboot
    winetricks msls31
    winetricks riched20

    ${wechatWine}/bin/wine64 regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine64 winecfg.exe
    ${wechatWine}/bin/wineserver -k
  '';
in
stdenv.mkDerivation {
  pname = "wine-wechat";
  inherit (sources.wine-wechat-x64) version;
  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    mkdir -p $out/bin $out/share/pixmaps
    cp -r ${startWechat} $out/bin/wine-wechat
    cp -r ${startWinecfg} $out/bin/wine-wechat-cfg
    cp -r ${./wine-wechat.png} $out/share/pixmaps/wine-wechat.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wine-wechat";
      exec = "wine-wechat";
      icon = "wine-wechat";
      desktopName = "Wine WeChat";
      comment = "Run WeChat with Wine";
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
        "Name[zh_CN]" = "Wine 微信";
        "Name[zh_TW]" = "Wine 微信";
        "Comment[zh_CN]" = "使用 Wine 运行微信";
        "Comment[zh_TW]" = "使用 Wine 运行微信";
      };
    })
    (makeDesktopItem {
      name = "wine-wechat-cfg";
      exec = "wine-wechat-cfg";
      icon = "wine-wechat";
      desktopName = "Wine WeChat config";
      comment = "Run winecfg for Wine WeChat";
      startupNotify = true;
      categories = [ "Settings" ];
      keywords = [
        "wx"
        "wechat"
        "weixin"
      ];
      extraConfig = {
        "Name[zh_CN]" = "Wine 微信配置";
        "Name[zh_TW]" = "Wine 微信配置";
        "Comment[zh_CN]" = "为 Wine 微信运行 winecfg";
        "Comment[zh_TW]" = "为 Wine 微信运行 winecfg";
      };
    })
  ];

  meta = with lib; {
    description = "Wine WeChat x64 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat)";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
