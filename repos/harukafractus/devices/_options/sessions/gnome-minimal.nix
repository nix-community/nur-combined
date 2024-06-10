{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.sessions.gnome-minimal;
in {
  options.sessions.gnome-minimal = {
    enable = mkEnableOption "Enable the GNOME, but without all the bloat";
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      enable = true;
      sessionPackages = [
        # Session Manager only; 
        # Not installing the metapackage
        pkgs.gnome.gnome-session.sessions
      ];
    };

    services.xserver.excludePackages = [ pkgs.xterm ];

    services.gnome = {
      core-shell.enable = true;         # Install package gnome-shell
      core-os-services.enable = true;   # Enables polkit, xdg, mime, dconf
      sushi.enable = true;              # File preview for nautilus
      at-spi2-core.enable = lib.mkForce false;
    };

    environment.systemPackages = with pkgs // pkgs.gnome; [
      gparted
      gnome-disk-utility
      baobab
      nautilus
      gnome-characters
      gnome-console
      gnome-color-manager
    ];

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      orca
      xterm
    ];
  };
}
