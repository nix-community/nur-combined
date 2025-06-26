{
  pkgs ? import <nixpkgs> { },
}:
let
  lib = pkgs.lib;
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

  splayer = pkgs.callPackage ./splayer rec {
    pnpm = pkgs.pnpm_10;
    hash = import ./splayer/hash.nix;
    sources = fetchedSrc.splayer;
    version = stableVersion sources;
  };
  splayer-git = pkgs.callPackage ./splayer rec {
    pnpm = pkgs.pnpm_10;
    hash = import ./splayer/hash-git.nix;
    sources = fetchedSrc.splayer-git;
    version = unstableVersion sources;
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
