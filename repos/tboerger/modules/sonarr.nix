{ pkgs, lib, config, options, ... }:
with lib;

let
  cfg = config.services.sonarr;

in
{
  options = {
    services.sonarr = {
      package = mkOption {
        type = types.package;
        default = pkgs.sonarr;
        defaultText = literalExpression "pkgs.sonarr";
        description = "Sonarr package to use";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.sonarr = {
      description = "Sonarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = mkForce "${cfg.package}/bin/NzbDrone -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };
  };
}
