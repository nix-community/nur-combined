{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.wluma;
in

{
  options.abszero.services.wluma.enable = mkEnableOption "automatic brightness adjustment";

  config = mkIf cfg.enable {
    systemd.packages = with pkgs; [ wluma ];
    services.udev.packages = with pkgs; [ wluma ];
  };
}
