{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:

rec {
  lmt = pkgs.callPackage ./pkgs/lmt { };
  obsidian-export = pkgs.callPackage ./pkgs/obsidian-export { };
  rancher-desktop = pkgs.callPackage ./pkgs/rancher-desktop { };
  raycast = pkgs.callPackage ./pkgs/raycast { };
  resilio-sync = pkgs.callPackage ./pkgs/resilio-sync { };
}
