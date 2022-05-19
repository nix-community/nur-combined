{ pkgs, lib, config, options, ... }:
with lib;

let
  cfg = config.services.radarr;

in
{
  options = {
    services.radarr = {
      package = mkOption {
        type = types.package;
        default = pkgs.radarr;
        defaultText = literalExpression "pkgs.radarr";
        description = "Radarr package to use";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.radarr = {
      description = "Radarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment.LD_LIBRARY_PATH="${lib.getLib pkgs.zlib}/lib";

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = mkForce "${cfg.package}/bin/Radarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };
  };
}
