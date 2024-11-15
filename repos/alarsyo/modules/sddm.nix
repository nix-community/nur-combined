{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.displayManager.sddm;
in {
  options.my.displayManager.sddm.enable = mkEnableOption "SDDM setup";

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      theme = "catppuccin-latte";
      wayland.enable = true;
    };

    environment.systemPackages = [
      (pkgs.catppuccin-sddm.override
        {
          flavor = "latte";
        })
    ];
  };
}
