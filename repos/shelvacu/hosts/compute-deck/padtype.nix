{ inputs, ... }:
let
  padtype-pkg = inputs.padtype.packages."x86_64-linux".default;
in
{
  environment.systemPackages = [ padtype-pkg ];

  systemd.services."padtype" = {
    wantedBy = [ "multi-user.target" ];
    script = "${padtype-pkg}/bin/padtype";
  };

  boot.initrd.preLVMCommands = "${padtype-pkg}/bin/padtype &";
  boot.initrd.kernelModules = [
    "uhid"
    "i2c_hid_acpi"
    "usbhid"
    "mac_hid"
    "evdev"
    "uinput"
  ];
}
