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
    #   systemPackages = with pkgs; [ ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      kdepim-runtime
      konsole
      plasma-browser-integration
    ];
  };
  programs = {
    sway.enable = mkForce false;
    hyprland.enable = mkForce false;
  };
  services = {
    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm.enable = true;
      ly.enable = lib.mkForce false;
    };
  };
}
