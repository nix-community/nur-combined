{ lib, config, ... }:

with lib;
let
  cfg = config.sane.gui.gnome;
in
{
  options = {
    sane.gui.gnome.enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    sane.programs.guiApps.enableFor.user.colin = true;

    # start gnome/gdm on boot
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # gnome does networking stuff with networkmanager
    networking.useDHCP = false;
    networking.networkmanager.enable = true;
    networking.wireless.enable = lib.mkForce false;
  };
  # user extras:
  # obtain these by running `dconf dump /` after manually customizing gnome
  # TODO: fix "is not of type `GVariant value'"
  # dconf.settings = lib.mkIf (gui == "gnome") {
  #   gnome = {
  #     # control alt-tab behavior
  #     "org/gnome/desktop/wm/keybindings" = {
  #       switch-applications = [ "<Super>Tab" ];
  #       switch-applications-backward=[];
  #       switch-windows=["<Alt>Tab"];
  #       switch-windows-backward=["<Super><Alt>Tab"];
  #     };
  #     # idle power savings
  #     "org/gnome/settings-deamon/plugins/power" = {
  #       idle-brigthness = 50;
  #       sleep-inactive-ac-type = "nothing";
  #       sleep-inactive-battery-timeout = 5400;  # seconds
  #     };
  #     "org/gnome/shell" = {
  #       favorite-apps = [
  #         "org.gnome.Nautilus.desktop"
  #         "firefox.desktop"
  #         "kitty.desktop"
  #         # "org.gnome.Terminal.desktop"
  #       ];
  #     };
  #     "org/gnome/desktop/session" = {
  #       # how long until considering a session idle (triggers e.g. screen blanking)
  #       idle-delay = 900;
  #     };
  #     "org/gnome/desktop/interface" = {
  #       text-scaling-factor = 1.25;
  #     };
  #     "org/gnome/desktop/media-handling" = {
  #       # don't auto-mount inserted media
  #       automount = false;
  #       automount-open = false;
  #     };
  #   };
  # };

}
