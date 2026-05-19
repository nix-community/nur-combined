{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.foot;
in

{
  options.abszero.themes.base.foot.enable = mkEnableOption "base foot theme";

  config.programs.foot.settings = mkIf cfg.enable {
    main.pad = "8x8center";
    cursor = {
      style = "beam";
      blink = "yes";
    };
  };
}
