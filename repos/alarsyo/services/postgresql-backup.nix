{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.postgresql-backup;
in {
  options.my.services.postgresql-backup = {
    enable = mkEnableOption "Backup SQL databases";
  };

  config = mkIf cfg.enable {
    services.postgresqlBackup = {
      enable = true;
      # Borg backup starts at midnight so create DB dump just before
      startAt = "*-*-* 23:30:00";
    };

    my.services.borg-backup = mkIf cfg.enable {
      paths = [ "/var/backup/postgresql" ];

      # no need to store previously backed up files, as borg does the snapshoting
      # for us
      exclude = [ "/var/backup/postgresql/*.prev.sql.gz" ];
    };
  };

}
