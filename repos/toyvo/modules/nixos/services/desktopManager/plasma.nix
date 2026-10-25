{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      xserver.enable = true;
      libinput.enable = true;
      displayManager.sddm.enable = true;
    };
    environment.systemPackages = with pkgs; [
      kate
      kdePackages.sddm-kcm
    ];
    catppuccin.sddm.enable = true;
  };
}
