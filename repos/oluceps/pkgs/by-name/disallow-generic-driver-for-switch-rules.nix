{ stdenv, writeText }:
## Usage
# In NixOS, simply add this package to services.udev.packages:
#   services.udev.packages = [ pkgs.opensk-udev-rules ];
let
  rule = writeText "10-disallow-generic-driver-for-switch.rules" ''
    # If
    # 1. a gamepad is multi-mode (Switch, X360, PC) and defaults to USB ID 057e:2009
    # AND at the same time
    # 2. `hid-nintendo` module can't be loaded (blacklisted or not compiled)
    # AND at the same time
    # 3. there's already a launched game that immediately grabs a gamepad,
    #
    # Then when you connect such gamepad, it will stay in "Switch Pro" mode,
    # but using the fallback `hid-generic` module
    # which would result in no vibration/etc
    # despite still being listed as a "Switch Pro Controller".

    # But by notifying the gamepad that we abandon to use it as an HID,
    # it automatically downgrades to "Xbox 360 Controller" mode,
    # which causes vibration and `xboxdrv` to work.
    SUBSYSTEM=="hid", DRIVER=="hid-generic", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", RUN="/bin/sh -c 'echo $id:1.0 > /sys/bus/usb/drivers/usbhid/unbind'"
  '';
in

stdenv.mkDerivation (finalAttrs: {
  pname = "disallow-generic-driver-for-switch-rules";

  version = "1";
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -D ${rule} $out/lib/udev/rules.d/10-disallow-generic-driver-for-switch.rules
    runHook postInstall
  '';
})
