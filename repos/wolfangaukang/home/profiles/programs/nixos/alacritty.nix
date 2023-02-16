{ pkgs, inputs, ... }:

let
  inherit (inputs) self;

in {
  imports = [
    "${self}/home/profiles/common/alacritty.nix"
  ];

  programs.alacritty.enable = true;
}
