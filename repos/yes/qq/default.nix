{ lib
, fetchurl
, mkElectronAppImage
, extraPkgs ? p: with p; [
    gjs               # screenshot support for GNOME Wayland
    libappindicator   # use appindicator instead of systray wherever possible
  ]
}:

mkElectronAppImage rec {
  inherit extraPkgs;
  pname = "qq";
  version = "3.1.1-11223";
  
  src = fetchurl {
    url = "https://dldir1.qq.com/qqfile/qq/QQNT/2355235c/linuxqq_${version}_x86_64.AppImage";
    hash = "sha256-J/Fa4Blz7yIW2E+odV6UmrxTX84R9SFOL5AskCe66w8=";
  };

  meta = {
    description = "Tencent QQ (upstream AppImage wrapped in FHS)";
    homepage = "https://im.qq.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}