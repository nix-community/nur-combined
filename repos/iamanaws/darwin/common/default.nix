{ config, lib, ... }:

with lib;
{
  time.timeZone = mkDefault (config.device.timezone or "UTC");
  environment.variables = {
    LANG = mkDefault (config.device.locale or "en_US.UTF-8");
  };
}
