# Third-party wired pad, VID 11c0 PID 5505 ("Xbox 360 for Windows Controller").
#
# Interface 0 is a standard XInput interface (ff/5d/01), but 11c0 is not in
# xpad's device table, so nothing binds it. Registering the ID at runtime
# lets xpad treat it as a wired Xbox 360 pad (it falls back to XTYPE_XBOX360
# for unknown vendor-class interfaces with protocol 1). The trailing "ff"
# restricts the match to the vendor-class interface, leaving interface 1
# (keyboard/mouse HID) to usbhid.
{
  flake.modules.nixos.gamepad =
    { pkgs, ... }:
    {
      boot.kernelModules = [ "xpad" ];
      services.udev.extraRules = ''
        # Dynamic IDs persist until reboot, so re-plugging hits EEXIST; ignore it.
        ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="11c0", ATTR{idProduct}=="5505", \
          RUN+="${pkgs.bash}/bin/sh -c 'echo 11c0 5505 ff > /sys/bus/usb/drivers/xpad/new_id || true'"
        # WebHID config / firmware update. No PID match on purpose:
        # bootloader mode may re-enumerate with a different PID.
        SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="11c0", MODE="0660", GROUP="users", TAG+="uaccess"
      '';
    };
}
