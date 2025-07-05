{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  fetchedSrc = pkgs.callPackage ../_sources/generated.nix { };
  stableVersion = src: lib.removePrefix "v" src.version;
  unstableVersion = src: "0-unstable-${src.date}";
in
rec {
  danmakufactory = pkgs.callPackage ./danmakufactory rec {
    sources = fetchedSrc.danmakufactory;
    version = stableVersion sources;
  };
  danmakufactory-git = pkgs.callPackage ./danmakufactory rec {
    sources = fetchedSrc.danmakufactory-git;
    version = unstableVersion sources;
  };

  mpv-handler = pkgs.callPackage ./mpv-handler rec {
    sources = fetchedSrc.mpv-handler;
    version = stableVersion sources;
  };

  shijima-qt = pkgs.callPackage ./shijima-qt { };

  inherit (pkgs) splayer;

  splayer-git = pkgs.callPackage ./splayer-git rec {
    hash = import ./splayer-git/hash-git.nix;
    sources = fetchedSrc.splayer-git;
    version = unstableVersion sources;
    inherit splayer;
  };

  uosc-danmaku = pkgs.mpvScripts.callPackage ./uosc-danmaku rec {
    inherit danmakufactory;
    sources = fetchedSrc.uosc-danmaku;
    version = stableVersion sources;
  };
  uosc-danmaku-git = pkgs.mpvScripts.callPackage ./uosc-danmaku rec {
    danmakufactory = danmakufactory-git;
    sources = fetchedSrc.uosc-danmaku-git;
    version = unstableVersion sources;
  };

  wpsoffice-365 = pkgs.libsForQt5.callPackage ./wpsoffice-365 { };
}
