{ config, lib, ... }:
let
  cfg = config.nixcfg.kanata;
in
{
  options.nixcfg.kanata.enable = lib.mkEnableOption "kanata keyboard remapping";

  config = lib.mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards.usbKeyboard = {
        devices = [
          "/dev/input/by-path/pci-0000:27:00.3-usb-0:3:1.0-event-kbd"
          "/dev/input/by-path/pci-0000:27:00.3-usbv2-0:3:1.0-event-kbd"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            caps
          )

          (defalias
            caps (tap-hold 100 100 esc lctl)
          )

          (deflayer base
            @caps
          )
        '';
      };
    };
  };
}
