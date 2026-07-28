{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  padtype-pkg = inputs.padtype.packages.${pkgs.stdenv.hostPlatform.system}.default;
  padtypeServiceConfig = {
    wantedBy = [ "sysinit.target" ];
    before = [ "cryptsetup.target" ];
    unitConfig = {
      DefaultDependencies = "no";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${padtype-pkg}/bin/padtype";
    };
  };
in
{
  environment.systemPackages = [ padtype-pkg ];

  systemd.services."padtype" = padtypeServiceConfig;
  boot.initrd.systemd.services."padtype" = padtypeServiceConfig;
  boot.initrd.systemd.storePaths = [ padtype-pkg ];

  # boot.initrd.preLVMCommands = lib.mkIf config.boot.initrd.systemd.enable ''
  #   ${padtype-pkg}/bin/padtype &
  # '';
  boot.initrd.kernelModules = [
    # "uhid"
    # "i2c_hid_acpi"
    "usbhid"
    # "mac_hid"
    "evdev"
    "uinput"
    "hid_steam"
    # "steamdeck"
  ];

  # #for debugging
  boot.kernelParams = [ "rd.systemd.debug_shell" ];
  # boot.initrd.systemd.emergencyAccess = true;
  # boot.initrd.extraUtilsCommands = ''
  #   copy_bin_and_libs ${pkgs.usbutils}/bin/lsusb
  #   copy_bin_and_libs ${pkgs.kmod}/bin/lsmod
  #   copy_bin_and_libs ${pkgs.kmod}/bin/modprobe
  #   copy_bin_and_libs ${padtype-pkg}/bin/list-devices
  #   copy_bin_and_libs ${padtype-pkg}/bin/padtype
  # '';

}
