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
    pname = "lx-music-desktop";
    version = "2.1.2";
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    src = fetchurl {
      url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
      hash = "sha256-xa0HR1u5GbfGU3hyu9Pjz8gKdIBhaSrh13ZfZ5FIMGM=";
    };
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  qq-appimage = callPackage ./electronAppImage rec {
    extraPkgs = p: with p; [ gjs libappindicator ];
    pname = "qq";
    version = "3.0.0-571";
    description = "Tencent QQ (upstream AppImage wrapped in FHS)";
    homepage = "https://im.qq.com";
    license = lib.licenses.unfree;
    src = fetchurl {
      url = "https://dldir1.qq.com/qqfile/qq/QQNT/c005c911/linuxqq_${version}_x86_64.AppImage";
      hash = "sha256-gKmk2m8pt2ygaHdFCWGo7+ZiQQ67VAvKH4o5OlwwPuE=";
    };
  };
}