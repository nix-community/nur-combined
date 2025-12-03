{
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

  programs = {
    sway.enable = mkForce false;
    hyprland.enable = mkForce false;
  };
  services = {
    cinnamon.apps.enable = false;
    xserver.desktopManager.cinnamon.enable = true;
  };
}
