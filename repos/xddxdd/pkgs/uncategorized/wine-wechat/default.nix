{ stdenv

  # WeChat replaces this download link with newer versions from time to time.
  # This package will inevitably break by then, but there's nothing I can do.
  # If that happens, change these two parameters.
, version ? "3.7.6"
, sha256 ? "sha256-FjK59BxgwLCmkDjgE2fsItCWwqBw0DOgtfrO/NuYwaY="

, fetchurl
, lib
, p7zip
, wine
, winetricks
, writeShellScript
, ...
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
    version = "2.47.2";
    src = fetchurl {
      url = "http://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.tar.xz";
      sha256 = "157akz7kqg6aja2a5rq096h3v2h39sxkwkj1xnzb1chh47m4dawg";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      tar xf ${src} -C $out
    '';
  };

  wechatWine = wine.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./wine-wechat.patch
    ];

    postInstall = (old.postInstall or "") + ''
      rm -rf $out/share/wine/gecko
      ln -sf ${wineGecko} $out/share/wine/gecko
    '';
  });

  wechatFiles = stdenv.mkDerivation rec {
    pname = "wechat";
    inherit version;

    # WeChat replaces this download link with newer versions from time to time.
    # This package will inevitably break by then, but there's nothing I can do.
    src = fetchurl {
      url = "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe";
      inherit sha256;
    };

    nativeBuildInputs = [ p7zip ];

    unpackPhase = ''
      7z x ${src}
      rm -rf \$*
    '';

    installPhase = ''
      mkdir $out
      cp -r * $out/
    '';
  };

  startWechat = writeShellScript "wine-wechat" ''
    export WINEARCH="win32"
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

    ${wechatWine}/bin/wine regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine ${wechatFiles}/WeChat.exe
    ${wechatWine}/bin/wineserver -k
  '';

  startWinecfg = writeShellScript "wine-wechat-cfg" ''
    export WINEARCH="win32"
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

    ${wechatWine}/bin/wine regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine winecfg.exe
    ${wechatWine}/bin/wineserver -k
  '';
in
stdenv.mkDerivation {
  pname = "wine-wechat";
  inherit version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${startWechat} $out/bin/wine-wechat
    ln -s ${startWinecfg} $out/bin/wine-wechat-cfg
    ln -s ${./share} $out/share
  '';

  meta = with lib; {
    description = "Wine WeChat";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
