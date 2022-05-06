{ pkgs }:

with pkgs;

{
  gogdl = python3Packages.callPackage ./gogdl { };
  iptvnator = callPackage ./iptvnator { };
  librewolf-bin = callPackage ./librewolf-bin { };
  multifirefox = callPackage ./multifirefox { };
  sherlock = callPackage ./sherlock { };
  signumone-ks = callPackage ./signumone-ks { };
  stremio = callPackage ./stremio { };
  upwork = callPackage ./upwork { };
  vdhcoapp = callPackage ./vdhcoapp {
    ffmpeg = if stdenv.isLinux && stdenv.isx86_64
               then ffmpeg-full
               else ffmpeg-full.override { libmfx = null; };
  };
}
