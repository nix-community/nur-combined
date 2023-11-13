{ lib, config, ... }:

let
  cfg = config.hardware.phicomm-n1;
in
{
  options.hardware = with lib; {
    phicomm-n1.dtos = mkOption {
      default = [ ];
      example = literalExpression ''
        [
          '''
            target = <&usb>;

            __overlay__ {
              dr_mode = "peripheral";
            };
          '''
        ]
      '';
      type = types.listOf types.str;
      description = mdDoc ''
        List of overlay fragments to apply to base device-tree (.dtb) files.
      '';
    };
  };

  config = with lib; {
    hardware.deviceTree = {
      enable = mkDefault true;
      name = mkDefault "amlogic/meson-gxl-s905d-phicomm-n1.dtb";
      filter = mkDefault "meson-gxl-s905d-phicomm-n1.dtb";
      overlays = [
        {
          name = "n1-overlay";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "amlogic,meson-gxl";

              fragment@0 {
                target = <&external_phy>;

                __overlay__ {
                  interrupts = <0x19 0x08>;
                };
              };

              ${concatLines (imap1 (i: v: "fragment@${toString i} {\n${v}\n};") cfg.dtos)}
            };
          '';
        }
      ];
    };
  };
}
