{pkgs ? import <nixpkgs> {}}:

rec {
  lorien = pkgs.callPackage ./lorien {};
  kickoff = pkgs.callPackage ./kickoff {};
  wired-notify = pkgs.callPackage ./wired-notify {};
  swayimg = pkgs.callPackage ./swayimg {};
  wldash = pkgs.callPackage ./wldash {};
  wlopm = pkgs.callPackage ./wlopm {};
  lswt = pkgs.callPackage ./lswt {};
  kile = pkgs.callPackage ./kile {};
}
