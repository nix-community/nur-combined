{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    heroic
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Enable gamemode
  programs.gamemode.enable = true;
}
