{ config, lib, ... }:

let
  cfg = config.hardware.phicomm-n1.dwc2;
in
{
  imports = [
    ./dtos.nix
  ];

  options.hardware = {
    phicomm-n1.dwc2 = {
      enable = lib.mkEnableOption ''
        Enable the UDC controller to support USB OTG gadget functions.

        In order to verify that this works, connect the USB port near the HDMI
        with another computer via the USB A cable, and then do one of:

        - `modprobe g_serial`
        - `modprobe g_mass_storage file=/path/to/some/iso-file.iso`

        On the Phicomm N1, `dmesg` should then show success-indicating output
        that is related to the dwc2 and g_serial/g_mass_storage modules.
        On the other computer, a serial/mass-storage device should pop up in
        the system logs.

        For more information about what gadget functions exist along with handy
        guides on how to test them, please refer to:
        https://www.kernel.org/doc/Documentation/usb/gadget-testing.txt
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.phicomm-n1.dtos = [
      ''
        target = <&usb>;

        __overlay__ {
          dr_mode = "peripheral";
        };
      ''
    ];
  };
}
