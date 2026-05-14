{
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";

  systemd.ctrlAltDelUnit = "poweroff.target";

  security.sudo.allowedCommands = [ "/run/current-system/sw/bin/poweroff" ];
}
