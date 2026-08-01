{ config, lib, ... }:

with lib;
{
  networking.hostName = mkDefault (config.device.hostname or "nixos");
  time.timeZone = mkDefault (config.device.timezone or "UTC");
  i18n.defaultLocale = mkDefault (config.device.locale or "en_US.UTF-8");
  system.stateVersion = mkDefault (config.device.stateVersion or "25.11");
}
