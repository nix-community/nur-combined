{
  hardware.enableRedistributableFirmware = true;

  services.fwupd.enable = true;
  systemd.services.fwupd-refresh.unitConfig.ConditionACPower = true;
}
