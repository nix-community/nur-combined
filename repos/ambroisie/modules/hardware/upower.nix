{ config, lib, ... }:
let
  cfg = config.my.hardware.upower;
in
{
  options.my.hardware.upower = with lib; {
    enable = mkEnableOption "upower configuration";

    levels = {
      low = mkOption {
        type = types.ints.unsigned;
        default = 25;
        example = 10;
        description = "Low percentage";
      };

      critical = mkOption {
        type = types.ints.unsigned;
        default = 15;
        example = 5;
        description = "Critical percentage";
      };

      action = mkOption {
        type = types.ints.unsigned;
        default = 5;
        example = 3;
        description = "Percentage at which point an action must be taken";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.upower = {
      enable = true;

      percentageLow = cfg.levels.low;

      percentageCritical = cfg.levels.critical;

      percentageAction = cfg.levels.action;
    };
  };
}
