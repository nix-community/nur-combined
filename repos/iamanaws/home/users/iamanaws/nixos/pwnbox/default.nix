{
  lib,
  pkgs,
  outputs,
  ...
}:

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

  home.packages = [ pkgs.pcmanfm ];

  wayland.windowManager.hyprland.settings.codeEditor._var = lib.mkForce "code";

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.home-manager.enable = true;

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";
}
