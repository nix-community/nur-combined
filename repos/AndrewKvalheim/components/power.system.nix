{
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";

  systemd.ctrlAltDelUnit = "poweroff.target";
}
