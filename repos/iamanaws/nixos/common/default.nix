{ config, lib, ... }:

{
  networking.hostName = lib.mkDefault config.device.hostname;
  time.timeZone = lib.mkDefault config.device.timezone;
  i18n.defaultLocale = lib.mkDefault config.device.locale;
  system.stateVersion = lib.mkDefault config.device.stateVersion;
}
