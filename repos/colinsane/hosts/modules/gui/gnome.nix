{ lib, config, pkgs, ... }:

let
  cfg = config.sane.gui.gnome;
in
{
  options = with lib; {
    sane.gui.gnome.enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    sane.programs.guiApps.enableFor.user.colin = true;

    # start gnome/gdm on boot
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    # gnome does networking stuff with networkmanager
    networking.networkmanager.enable = true;
    networking.wireless.enable = lib.mkForce false;


    # services.xserver.desktopManager.gnome.enable enables some default apps we don't really care about.
    # see <nixos/modules/services/x11/desktop-managers/gnome.nix>
    environment.gnome.excludePackages = with pkgs; [
      # gnome.gnome-menus  # unused outside gnome classic, but probably harmless
      gnome.gnome-control-center  #< if you want a faster deploy
      gnome-tour
    ];

    # disable these for a faster build cycle
    services.dleyna-renderer.enable = false;
    services.dleyna-server.enable = false;
    services.gnome.gnome-browser-connector.enable = false;
    services.gnome.gnome-initial-setup.enable = false;
    services.gnome.gnome-remote-desktop.enable = false;
    services.gnome.gnome-user-share.enable = false;
    services.gnome.rygel.enable = false;
    services.gnome.evolution-data-server.enable = lib.mkForce false;
    services.gnome.gnome-online-accounts.enable = lib.mkForce false;
    services.gnome.gnome-online-miners.enable = lib.mkForce false;
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
