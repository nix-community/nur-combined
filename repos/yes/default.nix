{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  archlinux = recurseIntoAttrs (import ./archlinux {
    inherit pkgs rp;
  });
  
  lx-music-desktop = callPackage ./electronAppImage rec {
    electron = electron_22;
    pname = "lx-music-desktop";
    version = "2.2.0";
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    src = fetchurl {
      url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
      hash = "sha256-cJQSfwNQ3iOHwRKiBXBAHWqs+A3Mi33Y/kBqPCKOzSI=";
    };
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  qq-appimage = callPackage ./electronAppImage rec {
    extraPkgs = p: with p; [
      gjs               # screenshot support for GNOME Wayland
      libappindicator   # use appindicator instead of systray wherever possible
    ];
    pname = "qq";
    version = "3.1.1-11223";
    description = "Tencent QQ (upstream AppImage wrapped in FHS)";
    homepage = "https://im.qq.com";
    license = lib.licenses.unfree;
    src = fetchurl {
      url = "https://dldir1.qq.com/qqfile/qq/QQNT/2355235c/linuxqq_${version}_x86_64.AppImage";
      hash = "sha256-J/Fa4Blz7yIW2E+odV6UmrxTX84R9SFOL5AskCe66w8=";
    };
  };

  snapgene-viewer = callPackage ./snapgene-viewer { };

  xonsh-direnv = callPackage ./xonsh-direnv { };
}