{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.services.btrbk;
in
{
  options.services.btrbk =
    {
      enable = mkEnableOption "btrbk service";
      config = mkOption {
        type = types.str;
        default = null;
      };
    };
  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.btrbk ];

    systemd.services.btrbk = {
      description = "btrbk backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart =
          let cfgFile = pkgs.writeText "btrbk.conf" cfg.config;
          in "${pkgs.btrbk}/bin/btrbk run -c ${cfgFile}";
      };
    };

    systemd.timers.btrbk = {
      description = "btrbk backup periodic";
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnUnitInactiveSec = "3min";
        OnBootSec = "3s";
      };
    };
  };


}
