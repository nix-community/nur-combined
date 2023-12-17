{pkgs ? import <nixpkgs> {}}:

rec {
  wldash = pkgs.callPackage ./wldash {};
}
