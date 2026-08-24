{
  fetchurl,
  stdenv,
  lib,
  nix-update-script,
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
in
stdenv.mkDerivation (finalAttrs: {
  pname = "wine-wechat-x86";
  version = "3.9.12.56";

  src = fetchurl {
    url = "https://github.com/tom-snow/wechat-windows-versions-x86/releases/download/v3.9.12.56/WeChatSetupX86-3.9.12.56.exe";
    hash = "sha256-luFiOhyEkCy/MxOKliV2xOjMxrq/kmWceiY/cDmo76k=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  postInstall =
    let
      wechatFiles = stdenv.mkDerivation {
        pname = "wechat-x86";
        inherit (finalAttrs) version src;
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
    ''
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
        "Comment[zh_CN]" = "使用 Wine 運行微信（x86）";
        "Comment[zh_TW]" = "使用 Wine 運行微信（x86）";
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
        "Comment[zh_TW]" = "為 Wine 微信（x86）運行 winecfg";
      };
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/tom-snow/wechat-windows-versions-x86/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Wine WeChat x86 (Packaging script adapted from https://aur.archlinux.org/packages/deepin-wine-wechat)";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "wine-wechat-x86";
  };
})
