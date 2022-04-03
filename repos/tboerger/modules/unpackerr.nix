{ pkgs, lib, config, options, ... }:

let
  cfg = config.services.unpackerr;
in

{
  options = with lib; {
    services.unpackerr = {
      enable = mkEnableOption "Unpackerr";

      user = mkOption {
        type = types.str;
        default = "unpackerr";
        description = "User account under which Unpackerr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "unpackerr";
        description = "Group under which Unpackerr runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.unpackerr = {
      description = "Unpackerr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.unpackerr}/bin/unpackerr";
        Restart = "on-failure";
      };
    };

    users.users = lib.mkIf (cfg.user == "unpackerr") {
      unpackerr = {
        group = cfg.group;
        home = "/var/lib/unpackerr";
        uid = config.ids.uids.unpackerr;
      };
    };

    users.groups = lib.mkIf (cfg.group == "unpackerr") {
      unpackerr = {
        gid = config.ids.gids.unpackerr;
      };
    };
  };
}
