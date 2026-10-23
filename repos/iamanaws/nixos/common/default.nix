{ config, lib, ... }:

with lib;
{
  networking.hostName = mkDefault config.device.hostname;
  time.timeZone = mkDefault config.device.timezone;
  i18n.defaultLocale = mkDefault config.device.locale;
  system.stateVersion = mkDefault config.device.stateVersion;
}
