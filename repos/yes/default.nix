{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  gnomeExtensions = recurseIntoAttrs (import ./gnomeExtensions {
    inherit pkgs rp;
  });
  
  lx-music-desktop = callPackage ./electronAppImage rec {
    pname = "lx-music-desktop";
    version = "1.22.2";
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = licenses.apl20;
    src = fetchurl {
      url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
      sha256 = "sha256-7pQbgY/eIknuUKmrn2YGKop75TVN7tLWAJjTIP/mjvY=";
    };
  };

  ppet = callPackage ./electronAppImage rec {
    electron = electron_16;
    pname = "ppet3";
    version = "3.3.0";
    description = "Live2D on desktop";
    homepage = "https://github.com/zenghongtu/PPet";
    license = licenses.mit;
    src = fetchurl {
      url = "${rp}${homepage}/releases/download/v${version}/PPet3-${version}.AppImage";
      sha256 = "sha256-zdRZm0T6tBqNxvaUaiWAlAfuug/CQX0S+B5uDNdiQ/s=";
    };
  };
}