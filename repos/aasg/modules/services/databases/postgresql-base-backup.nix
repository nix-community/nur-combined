{ config, lib, pkgs, ... }:

with lib;
let

  cfg = config.services.postgresqlBaseBackup;

in
{
  options = {
    services.postgresqlBaseBackup = {
      enable = mkEnableOption "PostgreSQL backups using pg_basebackup";

      location = mkOption {
        type = types.path;
        description = "directory where to store the backup.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.location} 0700 postgres postgres - -"
    ];

    systemd.services."postgresql-base-backup" = {
      description = "PostgreSQL database cluster backup";
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
      };
      restartIfChanged = false;
      preStart = ''
        ${pkgs.coreutils}/bin/rm -f ${cfg.location}/*
      '';
      script = toString [
        "${config.services.postgresql.package}/bin/pg_basebackup"
        "--port=${config.services.postgresql.port}"
        "--username=${config.services.postgresql.superUser}"
        "--pgdata=${cfg.location}"
        "--wal-method=stream"
      ];
    };
  };
}
