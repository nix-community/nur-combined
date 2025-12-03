{ config, ... }:
{
  vacu.packages = [ "tpm-fido" ];
  users.groups.uhid = { };
  users.users.shelvacu.extraGroups = [
    config.security.tpm2.tssGroup
    config.users.groups.uhid.name
  ];
  security.tpm2.enable = true;
  security.tpm2.applyUdevRules = true;
  services.udev.extraRules = ''
    KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="${config.users.groups.uhid.name}", MODE="0660"
  '';
}
