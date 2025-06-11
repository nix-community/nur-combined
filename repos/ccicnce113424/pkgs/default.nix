{
  pkgs ? import <nixpkgs>,
}:
let
  fetched-src = pkgs.callPackage ../_sources/generated.nix { };
in
rec {
  danmakufactory = pkgs.callPackage ./danmakufactory {
    sources = fetched-src.danmakufactory;
  };
  danmakufactory-git = pkgs.callPackage ./danmakufactory {
    sources = fetched-src.danmakufactory-git;
  };

  mpv-handler = pkgs.callPackage ./mpv-handler { sources = fetched-src.mpv-handler; };

  shijima-qt = pkgs.callPackage ./shijima-qt { };

  uosc-danmaku = pkgs.mpvScripts.callPackage ./uosc-danmaku {
    inherit danmakufactory;
    sources = fetched-src.uosc-danmaku;
  };
  uosc-danmaku-git = pkgs.mpvScripts.callPackage ./uosc-danmaku {
    danmakufactory = danmakufactory-git;
    sources = fetched-src.uosc-danmaku-git;
  };

  wpsoffice-365 = pkgs.libsForQt5.callPackage ./wpsoffice-365 { };
}
