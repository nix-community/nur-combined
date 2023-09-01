{ pkgs }:

let
  inherit (pkgs) stdenv callPackage recurseIntoAttrs electron_13 electron_22 ffmpeg-full;
  python3Packages = recurseIntoAttrs (import ./python-packages.nix { callPackage = pkgs.python3Packages.callPackage; });
  callPythonPackage = pkgs.python3Packages.callPackage;

in rec {
  inherit python3Packages;
  access-undenied-aws = callPythonPackage ../tools/security/access-undenied-aws { inherit (python3Packages) aws-error-utils; };
  burpsuite = callPackage ../tools/networking/burpsuite/ce.nix { };
  burpsuite-pro = callPackage ../tools/networking/burpsuite/pro.nix { };
  clair-scanner = callPackage ../development/tools/clair-scanner { };
  device-flasher = callPackage ../tools/misc/device-flasher { };
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
  pocket-casts = callPackage ../applications/audio/pocket-casts { electron = electron_22; };
  pricehist = callPythonPackage ../applications/misc/pricehist { inherit (python3Packages) curlify; };
  prowler = callPythonPackage ../tools/security/prowler { inherit (python3Packages) alive-progress; };
  prowler_2 = callPackage ../tools/security/prowler/2.nix { };
  sherlock = callPackage ../tools/security/sherlock { };
  signumone-ks = callPackage ../applications/misc/signumone-ks { };
  upwork = callPackage ../applications/misc/upwork { };
  upwork-wayland = callPythonPackage ../tools/misc/upwork-wayland { };
  vdhcoapp = callPackage ../tools/misc/vdhcoapp {
    ffmpeg = if stdenv.isLinux && stdenv.isx86_64
               then ffmpeg-full
               else ffmpeg-full.override { libmfx = null; };
  };
  xmouseless = callPackage ../tools/inputmethods/xmouseless { };
}
