{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    heroic
    mangohud
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extest.enable = true;
  };

  # Enable gamemode
  programs.gamemode.enable = true;
}
