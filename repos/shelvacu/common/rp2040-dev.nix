{
  config,
  lib,
  vacuModuleType,
  ...
}:
lib.optionalAttrs (vacuModuleType == "nixos") {
  services.udev.extraRules = ''
    # rp2040 dev
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", GROUP="${config.users.groups.dialout.name}", MODE="0660"
    SUBSYSTEM=="block", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", ENV{UDISKS_IGNORE}="1"
  '';
}
