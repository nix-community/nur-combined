{ pkgs, lib, config, inputs, ... }:

{
  languages.nix.enable = true;

  packages = with pkgs; [
    just
    cachix
  ];
}
