{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
