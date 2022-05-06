{ pkgs }:

{
  iptvnator = pkgs.callPackage ./iptvnator { };
  librewolf-bin = pkgs.callPackage ./librewolf-bin { };
  multifirefox = pkgs.callPackage ./multifirefox { };
  sherlock = pkgs.callPackage ./sherlock { };
  signumone-ks = pkgs.callPackage ./signumone-ks { };
  stremio = pkgs.callPackage ./stremio { };
  upwork = pkgs.callPackage ./upwork { };
  vdhcoapp = pkgs.callPackage ./vdhcoapp {
    ffmpeg = if pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64
               then pkgs.ffmpeg-full
               else pkgs.ffmpeg-full.override { libmfx = null; };
  };
}
