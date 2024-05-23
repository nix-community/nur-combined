{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.displayManager.sddm;
in

{
  options.abszero.services.displayManager.sddm.enable = mkEnableOption "sddm as the display manager";

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
    # Plasma integration
    environment.systemPackages =
      with pkgs;
      mkIf config.abszero.services.desktopManager.plasma6.enable [ kdePackages.sddm-kcm ];
  };
}
