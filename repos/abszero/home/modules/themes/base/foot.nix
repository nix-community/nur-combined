{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.foot;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.foot.enable = mkExternalEnableOption config "base foot theme";

  config.programs.foot.settings = mkIf cfg.enable {
    main.pad = "8x8center";
    cursor = {
      style = "beam";
      blink = "yes";
    };
  };
}
