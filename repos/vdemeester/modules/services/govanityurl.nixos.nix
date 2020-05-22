{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.govanityurl;
in
{
  options = {
    services.govanityurl = {
      enable = mkEnableOption ''
        govanityurl is a go canonical path server
      '';
      package = mkOption {
        type = types.package;
        default = pkgs.my.govanityurl;
        description = ''
          govanityurl package to use.
        '';
      };

      user = mkOption {
        type = types.str;
      };

      host = mkOption {
        type = types.str;
      };

      config = mkOption {
        type = types.lines;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.packages = [ cfg.package ];
    environment.etc."govanityurl/config.yaml".text = ''
      host: ${cfg.host}
      ${cfg.config}
    '';
    systemd.services.govanityurl = {
      description = "Govanity service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Restart = "on-failure";
        ExecStart = ''
          ${cfg.package}/bin/vanityurl /etc/govanityurl/config.yaml
        '';
      };
      path = [ cfg.package ];
    };
  };
}
