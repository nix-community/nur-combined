{ pkgs }:

with pkgs;

rec {
  access-undenied-aws = python3Packages.callPackage ./access-undenied-aws { inherit aws-error-utils; };
  aws-error-utils = python3Packages.callPackage ./aws-error-utils { };
  iptvnator = callPackage ./iptvnator { };
  librewolf-bin = callPackage ./librewolf-bin { };
  ly = callPackage ./ly { };
  mastopurge = callPackage ./mastopurge { };
  mouseless = callPackage ./mouseless { };
  multifirefox = callPackage ./multifirefox { };
  npm-groovy-lint = callPackage ./npm-groovy-lint { };
  nuclear = callPackage ./nuclear {
    electron = electron_13;
  };
  sherlock = callPackage ./sherlock { };
  signumone-ks = callPackage ./signumone-ks { };
  upwork = callPackage ./upwork { };
  vdhcoapp = callPackage ./vdhcoapp {
    ffmpeg = if stdenv.isLinux && stdenv.isx86_64
               then ffmpeg-full
               else ffmpeg-full.override { libmfx = null; };
  };
  xmouseless = callPackage ./xmouseless { };
}
