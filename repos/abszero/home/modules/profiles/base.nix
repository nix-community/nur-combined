{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.profiles.base;
in

{
  options.abszero.profiles.base.enable = mkEnableOption "base profile";

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    home = {
      stateVersion = "26.11";
      preferXdgDirectories = true;
      # NOTE: this doesn't enable pointerCursor by default.
      pointerCursor = {
        gtk.enable = mkDefault true;
        hyprcursor.enable = mkDefault true;
        x11.enable = mkDefault true;
      };
      # Create .profile so that greetd sets session variables before starting
      # the session, since it only sources .profile, not .zprofile nor
      # .bash_profile.
      # NOTE: hm-session-vars.sh makes sure it's only sourced once.
      file.".profile".text = ''
        . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      '';
    };

    xdg = {
      enable = true;
      autostart.enable = true;
      mimeApps.enable = true;
    };

    # gtk4 stopped being themed by default since 26.05
    gtk.gtk4.theme = mkDefault config.gtk.theme;

    programs = {
      bash = {
        enable = true;
        enableVteIntegration = true;
      };
      # NOTE: most of gpg config is in user's configuration
      gpg = {
        mutableKeys = mkDefault false;
        mutableTrust = mkDefault false;
      };
      home-manager.enable = true;
      nh = {
        enable = true;
        flake = "path:/home/weathercold/src/nixfiles";
        clean = {
          enable = true;
          extraArgs = "--keep 3 --keep-since 1w";
        };
      };
    };
  };
}
