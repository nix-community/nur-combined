{ config, lib, pkgs, nixosConfig, ... }:

{
  # home.file.".Xmodmap".source = ./xorg/Xmodmap;
  programs.autorandr.enable = nixosConfig.profiles.laptop.enable;
}
