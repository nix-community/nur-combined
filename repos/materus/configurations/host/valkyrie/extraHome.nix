{ config, pkgs, materusPkgs, lib, ... }:
{
  home.stateVersion = "23.05";
  home.homeDirectory = "/home/materus";

  materus.profile = {
    fonts.enable = false;
    nixpkgs.enable = true;
    enableDesktop = false;
    enableTerminal = true;
    enableTerminalExtra = false;
    enableNixDevel = false;
  };
}
