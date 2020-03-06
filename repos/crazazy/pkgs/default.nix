{ pkgs ? import <nixpkgs> {} }:
{
  # package sets
  js = import ./js { inherit pkgs; };

  # standalone packages
  nix-gen-node-tools = pkgs.callPackage ./gen-node-env { inherit (pkgs.nodePackages) node2nix; };
  efm-langserver = pkgs.callPackage ./efm-langserver {};
  ClassiCube = pkgs.callPackage ./ClassiCube {};

  # modules
  modules = import ../modules;
}
