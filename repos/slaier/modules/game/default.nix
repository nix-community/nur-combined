{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    lutris
    bottles
    heroic
  ];

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # Enable gamemode
  programs.gamemode.enable = true;
}
