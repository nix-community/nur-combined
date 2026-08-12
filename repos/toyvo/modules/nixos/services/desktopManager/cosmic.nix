{ lib, config, ... }:
let
  cfg = config.services.desktopManager.cosmic;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      displayManager.cosmic-greeter.enable = true;
      # Enable XWayland support in COSMIC
      desktopManager.cosmic.xwayland.enable = true;
      libinput.enable = true;
    };
  };
}
