{ config, lib, ... }:
let
  cfg = config.my.home.gammastep;

  mkTempOption = with lib; description: default: mkOption {
    inherit description default;
    type = types.int;
    example = 1000;
  };

  mkTimeOption = with lib; description: default: mkOption {
    inherit description default;
    type = types.str;
    example = "12:00-14:00";
  };
in
{
  options.my.home.gammastep = with lib; {
    enable = mkEnableOption "gammastep configuration";

    temperature = {
      day = mkTempOption "Colour temperature to use during the day" 6500;
      night = mkTempOption "Colour temperature to use during the night" 2000;
    };

    times = {
      dawn = mkTimeOption "Dawn time" "6:00-7:30";
      dusk = mkTimeOption "Dusk time" "18:30-20:00";
    };
  };

  config.services.gammastep = lib.mkIf cfg.enable {
    enable = true;

    tray = true;

    dawnTime = cfg.times.dawn;
    duskTime = cfg.times.dusk;

    temperature = {
      inherit (cfg.temperature) day night;
    };
  };
}
