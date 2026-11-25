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
  hmcl = pkgs.hmcl.override { inherit (packages) terracotta; };
  dsh-plugins = pkgs.callPackage ./pkgs/dsh-plugins { inherit (packages) deepseek-harness; };
  yesplaymusic = pkgs.callPackage ./pkgs/yesplaymusic {
    inherit (packages) yesplaymusic-plugins;
  };

  homeModules = import ./home-modules;
  nixosModules = import ./nixos-modules;
}
