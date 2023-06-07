{ config, pkgs, materusPkgs, lib, ... }:
{
  home.stateVersion = "23.05";
  home.homeDirectory = "/home/materus";
  materus.profile = {
    fonts.enable = false;
    nixpkgs.enable = false;
    enableDesktop = false;
    enableTerminal = false;
    enableTerminalExtra = false;
    enableNixDevel = false;

    fish.enable = true;
    bash.enable = true;
  };
}
