{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.pointerCursor;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.pointerCursor.enable =
    mkExternalEnableOption config "base cursor theme";

  config.programs.niri.settings.cursor = mkIf cfg.enable {
    theme = config.home.pointerCursor.name;
    size = config.home.pointerCursor.size;
  };
}
