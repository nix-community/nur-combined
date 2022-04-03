{ pkgs, lib, config, options, ... }:

let
  cfg = config.services.prowlarr;
in

{
  options = with lib; {
    services.prowlarr = {
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

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.prowlarr = {
      description = "Prowlarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = lib.mkForce {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.prowlarr}/bin/Prowlarr -nobrowser -data=${cfg.dataDir}";
        Restart = "on-failure";
      };
    };

    users.users = lib.mkIf (cfg.user == "prowlarr") {
      prowlarr = {
        group = cfg.group;
        home = "/var/lib/prowlarr";
        uid = config.ids.uids.prowlarr;
      };
    };

    users.groups = lib.mkIf (cfg.group == "prowlarr") {
      prowlarr = {
        gid = config.ids.gids.prowlarr;
      };
    };
  };
}
