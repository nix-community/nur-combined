{ pkgs, ... }:
{
  sane.programs.nix-tree = {
    packageUnwrapped = pkgs.nix-tree-rs;  #< XXX(2026-09-02): stock `nix-tree` fails on launch
    sandbox.extraPaths = [
      "/nix/var"
    ];
  };
}
