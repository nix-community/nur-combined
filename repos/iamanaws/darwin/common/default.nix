{ config, lib, ... }:

with lib;
{
  time.timeZone = mkDefault config.device.timezone;
  environment.variables = {
    LANG = mkDefault config.device.locale;
  };
}
