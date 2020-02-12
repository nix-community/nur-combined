{ pkgs ? import <nixpkgs> {} }:
{
  # package sets
  js = import ./js { inherit pkgs; };

  # standalone packages
  nix-gen-node-tools = pkgs.callPackage ./gen-node-env { inherit (pkgs.nodePackages) node2nix; };

  # modules
  modules = import ../modules;
}
