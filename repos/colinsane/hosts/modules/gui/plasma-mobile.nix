{ lib, config, ... }:
 
with lib;
let
  cfg = config.sane.gui.plasma-mobile;
in
{
  options = {
    sane.gui.plasma-mobile.enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    sane.programs.guiApps.enableFor.user.colin = true;

    # start plasma-mobile on boot
    services.xserver.enable = true;
    services.xserver.desktopManager.plasma5.mobile.enable = true;
    services.xserver.desktopManager.plasma5.mobile.installRecommendedSoftware = false;  # not all plasma5-mobile packages build for aarch64
    services.xserver.displayManager.sddm.enable = true;
   
    # Plasma does networking stuff with networkmanager, but nix configures the defaults itself
    # networking.useDHCP = false;
    # networking.networkmanager.enable = true;
    # networking.wireless.enable = lib.mkForce false;
  };
}
