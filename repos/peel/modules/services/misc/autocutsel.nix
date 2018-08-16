{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.autocutsel;
in
{
  options = {
    services.autocutsel = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable autocutsel.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."autocutsel" = {
      enable = true;
      description = "AutoCutSel";
      wantedBy = [ "default.target" ];
      serviceConfig.Type = "forking";
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStartPre = "${pkgs.autocutsel}/bin/autocutsel -fork";
      serviceConfig.ExecStart = "${pkgs.autocutsel}/bin/autocutsel -selection PRIMARY -fork";
    };
  };
}
