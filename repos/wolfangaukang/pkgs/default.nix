{ pkgs }:

with pkgs;

{
  python3Packages = recurseIntoAttrs (
    let
      inherit (python3.pkgs) callPackage;
    in rec {
      access-undenied-aws = callPackage ./development/python-modules/access-undenied-aws { inherit aws-error-utils; };
      aws-error-utils = callPackage ./development/python-modules/aws-error-utils { };
    }
  ); 

  iptvnator = callPackage ./applications/video/iptvnator { };
  ly = callPackage ./applications/display-managers/ly { };
  mastopurge = callPackage ./tools/misc/mastopurge { };
  mouseless = callPackage ./tools/inputmethods/mouseless { };
  multifirefox = callPackage ./applications/networking/browsers/multifirefox { };
  npm-groovy-lint = callPackage ./development/tools/npm-groovy-lint { };
  nuclear = callPackage ./applications/audio/nuclear {
    electron = electron_13;
  };
  sherlock = callPackage ./tools/security/sherlock { };
  signumone-ks = callPackage ./applications/misc/signumone-ks { };
  upwork = callPackage ./applications/misc/upwork { };
  vdhcoapp = callPackage ./tools/misc/vdhcoapp {
    ffmpeg = if stdenv.isLinux && stdenv.isx86_64
               then ffmpeg-full
               else ffmpeg-full.override { libmfx = null; };
  };
  xmouseless = callPackage ./tools/inputmethods/xmouseless { };
}
