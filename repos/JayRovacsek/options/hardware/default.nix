{ lib, pkgs, config, ... }:
with lib;
let cfg = config.hardware.cpu.profile;
in {
  options.hardware.cpu.profile = {
    cores = mkOption {
      type = types.int;
      default = 1;
      description = "The number of CPU cores available on the system";
    };
    speed = mkOption {
      type = types.int;
      default = 1;
      description =
        "The relative speed of CPU cores compared to other systems within configuration";
    };
  };
}
