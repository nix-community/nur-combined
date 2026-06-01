{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.easyeffects;
in
{
  options.nixcfg.easyeffects.enable = lib.mkEnableOption "easyeffects service";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux && (config.nixcfg.gui.enable or false)) {
    services.easyeffects.enable = true;
  };
}
