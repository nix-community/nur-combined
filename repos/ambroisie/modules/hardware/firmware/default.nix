{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.firmware;
in
{
  options.my.hardware.firmware = with lib; {
    enable = my.mkDisableOption "firmware configuration";

    cpuFlavor = mkOption {
      type = with types; nullOr (enum [ "intel" "amd" ]);
      default = null;
      example = "intel";
      description = "Which kind of CPU to activate micro-code updates";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      hardware = {
        enableRedistributableFirmware = true;
      };
    }

    # Intel CPU
    (lib.mkIf (cfg.cpuFlavor == "intel") {
      hardware = {
        cpu.intel.updateMicrocode = true;
      };
    })

    # AMD CPU
    (lib.mkIf (cfg.cpuFlavor == "amd") {
      hardware = {
        cpu.amd.updateMicrocode = true;
      };
    })
  ]);
}
