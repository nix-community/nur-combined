{
  outputs,
  ...
}:

let
  flakeOverlays = if outputs ? overlays then outputs.overlays else import ../../../../overlays;
in
{
  imports = [
    ../../config/shell
    ../../config/shell/bash.nix
    ../../config/dunst
    ../../config/kitty.nix
    ../../config/hypr/hyprlock/hyprlock.nix
    ../../config/hypr/hyprland.nix
    ../../config/hypr/hyprpaper.nix
    ./waybar.nix
    ./browser.nix
  ];

  home = {
    username = "iamanaws";
    homeDirectory = "/home/iamanaws";
  };

  home.packages = [ ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.home-manager.enable = true;

  nixpkgs = {
    overlays = [
      flakeOverlays.additions
      flakeOverlays.modifications
    ];
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
