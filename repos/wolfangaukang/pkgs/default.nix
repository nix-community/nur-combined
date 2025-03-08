{ pkgs }:

let
  inherit (pkgs) callPackage;
  callPythonPackage = pkgs.python3Packages.callPackage;

in
{
  access-undenied-aws = callPythonPackage ./access-undenied-aws { };
  burpsuite = callPackage ./burpsuite/ce.nix { };
  burpsuite-pro = callPackage ./burpsuite/pro.nix { };
  clair-scanner = callPackage ./clair-scanner { };
  iptvnator = callPackage ./iptvnator { };
  mkat = callPackage ./mkat { };
  mouseless = callPackage ./mouseless { };
  npm-groovy-lint = callPackage ./npm-groovy-lint { };
  upwork-wayland = callPythonPackage ./upwork-wayland { };
  xmouseless = callPackage ./xmouseless { };
}
