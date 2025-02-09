{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.ghostty;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.ghostty.enable = mkExternalEnableOption config "base ghostty theme";

  config.programs.ghostty.settings = mkIf cfg.enable {
    window-padding-x = 8;
    window-padding-y = 8;
    window-padding-balance = true;
    window-padding-color = "extend";
  };
}
