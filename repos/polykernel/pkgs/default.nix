{pkgs ? import <nixpkgs> {}}:

rec {
  lorien = pkgs.callPackage ./lorien {};
  wired-notify = pkgs.callPackage ./wired-notify {};
  wldash = pkgs.callPackage ./wldash {};
  wlopm = pkgs.callPackage ./wlopm {};
  lswt = pkgs.callPackage ./lswt {};
  kile = pkgs.callPackage ./kile {};
}
