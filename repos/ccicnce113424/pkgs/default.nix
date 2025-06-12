{
  pkgs ? import <nixpkgs> { },
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

  splayer = pkgs.callPackage ./splayer {
    pnpm = pkgs.pnpm_10;
    hash = import ./splayer/hash.nix;
    sources = fetched-src.splayer;
  };
  splayer-git = pkgs.callPackage ./splayer {
    pnpm = pkgs.pnpm_10;
    hash = import ./splayer/hash-git.nix;
    sources = fetched-src.splayer-git;
  };

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
