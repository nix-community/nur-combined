{
  pkgs ? import <nixpkgs> { },
}:

let
  packages = builtins.mapAttrs (name: _: pkgs.callPackage (./pkgs + "/${name}") { }) (
    pkgs.lib.filterAttrs (name: _: builtins.pathExists (./pkgs + "/${name}/default.nix")) (
      builtins.readDir ./pkgs
    )
  );
in
packages
// {
  dsh-plugins = pkgs.callPackage ./pkgs/dsh-plugins { inherit (packages) deepseek-harness; };
  hmcl = pkgs.hmcl.override { inherit (packages) terracotta; };

  homeModules = import ./home-modules;
  nixosModules = import ./nixos-modules;
}
