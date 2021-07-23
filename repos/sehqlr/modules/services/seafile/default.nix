{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.seafile;
in {
  # INTERFACE
  options.services.seafile = {
    enable = mkEnableOption "Enable seafile file sync server";
    package = mkOption {
        type = types.package;
        default = pkgs.seafile-shared;
        description = "Package to use for seafile";
    };
    dataDir = mkOption {
        type = types.path;
        default = "/var/lib/seafile";
        example = "/srv/seafile_data";
        description = "Seafile server data directory";
    };
    user = mkOption {
        type = types.str;
        default = "seafserver";
        description = "Name of system user & group to use with service";
  };

  # IMPLEMENTATION
  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    services.mysql.enable = true;

    services.postfix = {
        enable = true;
    };

    systemd.services = {
        "seafile" = {
            enable = true;
            after = ["network.target" "mysql.service"];
            description = "Seafile file sync service";
            documentation = ["https://seafile.readthedocs.io/en/latest/"];
            preStop = "${cfg.package}/bin/seafile.sh stop";
            start = "${cfg.package}/bin/seafile.sh start";
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
                User = cfg.user;
                Group = cfg.user;
            };
            wantedBy = [ "multi-user.target" ];
        };
        "seahub" = {
            enable = true;
            after = ["seafile.service"];
            description = "Seafile hub (web) service";
            documentation = ["https://seafile.readthedocs.io/en/latest/"];
            preStop = "${cfg.package}/bin/seahub.sh stop";
            start = "${cfg.package}/bin/seahub.sh start";
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = "yes";
                User = cfg.user;
                Group = cfg.user;
            };
            wantedby = [ "multi-user.target" ];
        };
    };
    
    users.extraUsers.${cfg.user} = {
      group = cfg.user;
      isSystemUser = true;
      createHome = true;
      home = cfg.dataDir;
      description = "Seafile Server";
    };
  };
}
