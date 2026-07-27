{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.dptfxtract;

in

{
  options = {
    services.dptfxtract = {
      enable = mkEnableOption "Extract DPTF tables for use with thermald";

      configIndex = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = ''
          Configuration file index to pass to thermald
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.thermald = {
      enable = true;
      configFile = mkDefault "/etc/thermald/thermal-conf.xml.${
        if cfg.configIndex == null
        then "auto"
        else toString cfg.configIndex
      }";
    };

    systemd.services.dptfxtract = {
      description = "Extract DPTF tables for thermald";
      requiredBy = [ "thermald.service" ];
      before = [ "thermald.service" ];
      serviceConfig.type = "oneshot";

      script = /* sh */ ''
        ${pkgs.nur.repos.rummik.dptfxtract}/sbin/dptfxtract
      '';
    };
  };
}
