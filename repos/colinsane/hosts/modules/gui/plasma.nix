{ lib, config, ... }:

with lib;
let
  cfg = config.sane.gui.plasma;
in
{
  options = {
    sane.gui.plasma.enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    sane.programs.guiApps.enableFor.user.colin = true;

    # start plasma on boot
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.displayManager.sddm.enable = true;

    # gnome does networking stuff with networkmanager
    networking.useDHCP = false;
    networking.networkmanager.enable = true;
    networking.wireless.enable = lib.mkForce false;
  };
}
