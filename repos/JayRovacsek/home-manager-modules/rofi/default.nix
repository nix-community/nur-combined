{ config, pkgs, lib, osConfig, ... }:
let
  # Hack to make home manager module that is linux
  # specific not cause explosions if accidentally loaded onto
  # a non-linux system.
  inherit (lib.strings) hasInfix;
  enable = hasInfix "linux" osConfig.nixpkgs.system;
in {
  programs.rofi = {
    inherit enable;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./themes/launchpad.rasi;
    extraConfig.modi = "drun";
  };
}
