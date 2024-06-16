{ lib, pkgs, config, ... }:
with lib;                      
let
  cfg = config.sessions.ibus-engines;
in {
  options.sessions.ibus-engines = {
    enable = mkEnableOption "Enable ibus engine for rime & mozc";
  };

  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ rime mozc ];
    };
  };
}