{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.dptf;
  pkg = pkgs.nur.repos.rummik.dptf;

in

{
  options = {
    services.dptf = {
      enable = mkEnableOption "Enable Intel Dynamic Tuning daemon";
    };
  };

  config = mkIf cfg.enable {
    #boot.kernelModules = [ "dtpf_power" ];
    #add_drivers+=" intel_soc_dts_iosf processor_thermal_device int3403_thermal int340x_thermal_zone int3400_thermal acpi_thermal_rel "

    systemd.services.dptf = {
      description = "Intel Dynamic Tuning daemon";
      wantedBy = [ "sysinit.target" ];

      conflicts = [ ];

      serviceConfig = {
        Type = "forking";
        Restart = "always";
        ExecStart = "${pkg}/bin/esif_ufd -l -x";
      };
    };
  };
}

