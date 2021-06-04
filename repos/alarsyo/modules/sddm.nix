{ config, lib, pkgs, ... }:
let
  cfg = config.my.displayManager.sddm;
in
{
  options.my.displayManager.sddm.enable = lib.mkEnableOption "SDDM setup";

  config = lib.mkIf cfg.enable {
    services.xserver.displayManager.sddm = {
      enable = true;
      theme = "sugar-candy";
    };

    environment.systemPackages = with pkgs; [
      packages.sddm-sugar-candy

      # dependencies for sugar-candy theme
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols2
      libsForQt5.qt5.qtsvg
    ];
  };
}
