{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.modules.desktop.wayland.sway;
in
{
  options = {
    modules.desktop.wayland.sway = {
      enable = mkEnableOption "Enable sway desktop profile";
    };
  };
  config = mkIf cfg.enable {
    # Enable wayland desktop modules if not already
    modules.desktop.wayland.enable = true;

    # Enable pipewire
    modules.hardware.audio = {
      enable = true;
      pipewire.enable = true;
    };

    services.blueman.enable = config.modules.hardware.bluetooth.enable;

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
      };
    };

    # Allow swaylock to unlock the computer for us
    security.pam.services.swaylock = {
      text = "auth include login";
    };

    # FIXME are those needed
    programs.dconf.enable = true;
    services.dbus = {
      enable = true;
      packages = [ pkgs.dconf pkgs.gcr ];
    };
  };
}

