{ pkgs }:

let
  inherit (pkgs) python310 stdenv callPackage recurseIntoAttrs electron_13 ffmpeg-full;
  python3Packages = recurseIntoAttrs (python310.pkgs.callPackage ./python-packages.nix { });
  callPythonPackage = python3Packages.callPackage;
in rec {
  inherit python3Packages;
  access-undenied-aws = callPythonPackage ../tools/security/access-undenied-aws { };
  dsnap = callPythonPackage ../development/python-modules/dsnap { };
  iptvnator = callPackage ../applications/video/iptvnator { };
  ly = callPackage ../applications/display-managers/ly { };
  mastopurge = callPackage ../tools/misc/mastopurge { };
  mouseless = callPackage ../tools/inputmethods/mouseless { };
  multifirefox = callPackage ../applications/networking/browsers/multifirefox { };
  npm-groovy-lint = callPackage ../development/tools/npm-groovy-lint { };
  nuclear = callPackage ../applications/audio/nuclear {
    electron = electron_13;
  };
  pacu = callPythonPackage ../tools/security/pacu { inherit dsnap; };
  sherlock = callPackage ../tools/security/sherlock { };
  signumone-ks = callPackage ../applications/misc/signumone-ks { };
  upwork = callPackage ../applications/misc/upwork { };
  vdhcoapp = callPackage ../tools/misc/vdhcoapp {
    ffmpeg = if stdenv.isLinux && stdenv.isx86_64
               then ffmpeg-full
               else ffmpeg-full.override { libmfx = null; };
  };
  xmouseless = callPackage ../tools/inputmethods/xmouseless { };
}
