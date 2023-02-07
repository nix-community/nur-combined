{ lib, pkgs, config, ... }:

with lib;

let cfg = config.hardware.deviceTree.raspberryPi;

in {
  options = {
    hardware.deviceTree.raspberryPi = {
      enable = mkEnableOption "Raspberry Pi specific dtparams and dtoverlays";

      overlays = mkOption { type = with types; listOf path; };

      params = mkOption { type = with types; attrsOf str; };
    };
  };

  config = mkIf cfg.enable {
    hardware.deviceTree.package = mkForce
      (pkgs.runCommand "device-tree-overlays" {
        buildInputs = with pkgs; [ findutils libraspberrypi ];
      } ''
        cd ${config.boot.kernelPackages.kernel}/dtbs
        for dtb in $(find . -type f -name "${config.hardware.deviceTree.filter}")
        do
          install -D $dtb $out/$dtb

          ${
            concatStrings (mapAttrsToList (name: value: ''
              dtmerge -d $out/$dtb $out/$dtb - ${name}=${value}
            '') cfg.params)
          }

          ${
            concatMapStrings (overlay: ''
              dtmerge -d $out/$dtb $out/$dtb ${overlay}
            '') cfg.overlays
          }
        done
      '');
  };
}

