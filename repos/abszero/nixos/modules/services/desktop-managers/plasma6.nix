{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.abszero.services.desktopManager.plasma6;
in

{
  options.abszero.services.desktopManager.plasma6.enable = mkEnableOption "the next generation desktop for Linux";

  config = mkIf cfg.enable {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm.wayland.compositor = "kwin";
    };

    environment.systemPackages =
      with pkgs;
      mkMerge [
        # SDDM integration
        (mkIf config.abszero.services.displayManager.sddm.enable [ kdePackages.sddm-kcm ])
        [
          clinfo # For Plasma Info Center
          glxinfo # For Plasma Info Center
          pciutils # For Plasma Info Center
          vulkan-tools # For Plasma Info Center
          wayland-utils # For Plasma Info Center
        ]
      ];
  };
}
