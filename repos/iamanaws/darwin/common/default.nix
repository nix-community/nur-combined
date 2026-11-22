{ config, lib, ... }:

{
  time.timeZone = lib.mkDefault config.device.timezone;
  environment.variables = {
    LANG = lib.mkDefault config.device.locale;
  };
}
