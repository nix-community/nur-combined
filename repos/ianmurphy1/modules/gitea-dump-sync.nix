{
  config,
  lib,
  pkgs,
  ...
}:
let 
  cfg = config.services.gitea-dump-sync;
  backupsEnabled = config.services.gitea.dump.enable;

  gitea-dump-sync = {
    enable = true;

    description = "Enables syncing gitea backups to R2";

    requires = [
      "gitea.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "gitea";
      ExecStart = "${lib.getExe cfg.package}";
      WorkingDirectory = "${cfg.location}";
      UMask = "0077";
    };

    environment = lib.mkMerge [
      {
        RCLONE_CONFIG = cfg.rcloneConfig;
        R2_RCLONE_PROFILE = cfg.r2RcloneProfile;
        R2_BUCKET = cfg.r2Bucket;
        BACKUP_FILE = cfg.backupFile;
        BACKUPS_DIR = cfg.location;
     }

     (lib.mkIf cfg.enableDebug {
       DEBUG = "true";
     })
   ];

    startAt = cfg.startAt;
  };
in
  {
    options = {
      services.gitea-dump-sync = {
        enable = lib.mkEnableOption "gitea dump sync";

        package = lib.mkOption {
          type = lib.types.package;
          default = (pkgs.callPackage ../. {}).r2-sync;
        };

        backupFile = lib.mkOption {
          type = lib.types.str;
          description = "Path to the file to backup";
          default = "dump.tar.xz";
        };

        location = lib.mkOption {
          type = lib.types.path;
          description = "Location of the backups to sync";
          default = "${config.services.gitea.dump.backupDir}";
        };

        rcloneConfig = lib.mkOption {
          type = lib.types.path;
          description = "Path to where the config for rclone if located";
          default = "/root/.config/rclone/rclone.conf";
        };

        r2Bucket = lib.mkOption {
          type = lib.types.str;
          description = "The r2 bucket to sync to";
          default = "gitea-backups";
        };

        r2RcloneProfile = lib.mkOption {
          type = lib.types.str;
          description = "The rclone profile where r2 creds are created";
          default = "backups";
        };

        enableDebug = lib.mkOption {
          type = lib.types.bool;
          description = "Whether to enable debug logging within the service";
          default = false;
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

    config = lib.mkIf ( cfg.enable && backupsEnabled ) {
      systemd.services.gitea-dump-sync = gitea-dump-sync;
    };
  }
