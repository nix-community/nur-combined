{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.services.postgresBackupSync;

  postgresBackupSync = {
    enable = true;

    description = "Enables syncing backups to R2";

    requires = [
      "postgresqlBackup.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${lib.getExe cfg.package}";
      WorkingDirectory = "${cfg.location}";
    };
    environment = {
      RCLONE_CLONE_CONFIG = cfg.rcloneConfig;
      R2_RCLONE_PROFILE = cfg.r2RcloneProfile;
      R2_BUCKET = cfg.r2Bucket;
      BACKUP_FILE = cfg.backupFile;
      BACKUPS_DIR = cfg.location;
    };

    startAt = cfg.startAt;
  };
in
  {
    options = {
      services.postgresBackupSync = {
        enable = lib.mkEnableOption "PostgreSQL dump sync";

        package = lib.mkOption {
          type = lib.types.package;
          default = (pkgs.callPackage ../. {}).r2-sync;
        };

        backupFile = lib.mkOption {
          type = lib.types.str;
          description = "Path to the file to backup";
          default = "all.sql.gz";
        };

        location = lib.mkOption {
          type = lib.types.path;
          description = "Location of the backups to sync";
          default = "${config.services.postgresqlBackup.location}";
        };

        rcloneConfig = lib.mkOption {
          type = lib.types.path;
          description = "Path to where the config for rclone if located";
          default = "/root/.config/rclone/rclone.conf";
        };

        r2Bucket = lib.mkOption {
          type = lib.types.str;
          description = "The r2 bucket to sync to";
          default = "postgres-backups";
        };

        r2RcloneProfile = lib.mkOption {
          type = lib.types.str;
          description = "The rclone profile where r2 creds are created";
          default = "backups";
        };

        startAt = lib.mkOption {
          default = "*-*-* 01:20:00";
          type = with lib.types; either (listOf str) str;
          description = ''
            This option defines (see `systemd.time` for format) when the
            sync will occur. As the default for postgresqlBackup service
            is to run at `01:15:00` offset this one by 5 minutes.
            Time may need to be adjusted depending on how long it takes for
            the backup service to complete
          '';
        };
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.postgresBackupSync = postgresBackupSync;
    };
  }
