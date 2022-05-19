{ pkgs, lib, config, options, ... }:
with lib;

let
  cfg = config.services.prowlarr;

in
{
  options = {
    services.prowlarr = {
      package = mkOption {
        type = types.package;
        default = pkgs.prowlarr;
        defaultText = literalExpression "pkgs.prowlarr";
        description = "Prowlarr package to use";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/prowlarr";
        description = "The directory where Prowlarr stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = "prowlarr";
        description = "User account under which Prowlarr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "prowlarr";
        description = "Group under which Prowlarr runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.prowlarr = {
      description = "Prowlarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = mkForce "${cfg.package}/bin/Prowlarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "prowlarr") {
      prowlarr = {
        group = cfg.group;
        home = "/var/lib/prowlarr";
        uid = config.ids.uids.prowlarr;
      };
    };

    users.groups = mkIf (cfg.group == "prowlarr") {
      prowlarr = {
        gid = config.ids.gids.prowlarr;
      };
    };
  };
}
