{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkForce;

in
{
  imports = [
    ./xserver.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      pantheon.elementary-files
      pantheon-tweaks
    ];
    pantheon.excludePackages = with pkgs; [
      # GNOME Browser
      epiphany
      # Email related stuff
      evolutionWithPlugins
      geary
    ];
  };
  programs = {
    sway.enable = mkForce false;
    hyprland.enable = mkForce false;
  };
  services = {
    pantheon = {
      apps.enable = false;
      contractor.enable = true;
    };
    xserver = {
      desktopManager.pantheon.enable = true;
      displayManager.lightdm.greeters.pantheon.enable = true;
    };
    displayManager.ly.enable = lib.mkForce false;
  };
}
