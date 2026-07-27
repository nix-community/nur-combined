{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkDefault;
  cfg = config.modules.desktop.xorg;
in
{
  options = {
    modules.desktop.xorg = {
      enable = mkEnableOption "Enable Xorg desktop";
    };
  };
  config = mkIf cfg.enable {
    modules.desktop.enable = true;
    # Extra packages to add to the system
    environment.systemPackages = with pkgs; [
      xorg.xmessage
    ];

    services = {
      # Enable xserver on desktop
      xserver = {
        enable = true;
        enableTCP = false;
        libinput.enable = true;
        synaptics.enable = false;
        layout = "fr";
        xkbVariant = "bepo";
        xkbOptions = "grp:menu_toggle,grp_led:caps,compose:caps";
      };
    };

  };
}
