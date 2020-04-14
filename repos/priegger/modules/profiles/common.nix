{ config, lib, pkgs, ... }:
with lib;

{
  # Select internationalisation properties.
  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
  };

  console = {
    font = mkDefault "Lat2-Terminus16";
    keyMap = mkDefault "de";
  };

  environment.variables = {
    LC_TIME = mkDefault "en_GB.UTF-8";
    LC_PAPER = mkDefault "en_GB.UTF-8";
    LC_MEASUREMENT = mkDefault "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = mkDefault "Europe/Berlin";

  # Increase size of /run/user directories
  services.logind.extraConfig = ''
    RuntimeDirectorySize=2G
  '';

  # Reduce journal size
  services.journald.extraConfig = ''
    Storage=persistent
    SystemMaxUse=512M
  '';

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = mkDefault true;
    logLevel = mkDefault "ERROR";
    passwordAuthentication = mkDefault false;
  };
}
