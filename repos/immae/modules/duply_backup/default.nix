{ lib, pkgs, config, ... }:

let
  cfg = config.myEnv.backup;
  varDir = "/var/lib/duply";
  duplyProfile = profile: prefix: ''
    GPG_PW="${cfg.password}"
    TARGET="${cfg.remote}${prefix}"
    export AWS_ACCESS_KEY_ID="${cfg.accessKeyId}"
    export AWS_SECRET_ACCESS_KEY="${cfg.secretAccessKey}"
    SOURCE="${profile.rootDir}"
    FILENAME=".duplicity-ignore"
    DUPL_PARAMS="$DUPL_PARAMS --exclude-if-present '$FILENAME'"
    VERBOSITY=4
    ARCH_DIR="${varDir}/caches"

    # Do a full backup after 1 month
    MAX_FULLBKP_AGE=1M
    DUPL_PARAMS="$DUPL_PARAMS --full-if-older-than $MAX_FULLBKP_AGE "
    # Backups older than 2months are deleted
    MAX_AGE=2M
    # Keep 2 full backups
    MAX_FULL_BACKUPS=2
    MAX_FULLS_WITH_INCRS=2
  '';
  action = "bkp_purge_purgeFull_purgeIncr";
in
{
  options = {
    services.duplyBackup.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable remote backups.
      '';
    };
    services.duplyBackup.profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          rootDir = lib.mkOption {
            type = lib.types.path;
            description = ''
              Path to backup
              '';
          };
          excludeFile = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = ''
              Content to put in exclude file
              '';
          };
        };
      });
    };
  };

  config = lib.mkIf config.services.duplyBackup.enable {
    system.activationScripts.backup = ''
      install -m 0700 -o root -g root -d ${varDir} ${varDir}/caches
      '';
    secrets.keys = lib.flatten (lib.mapAttrsToList (k: v: [
      {
        permissions = "0400";
        dest = "backup/${k}/conf";
        text = duplyProfile v "${k}/";
      }
      {
        permissions = "0400";
        dest = "backup/${k}/exclude";
        text = v.excludeFile;
      }
    ]) config.services.duplyBackup.profiles);

    services.cron = {
      enable = true;
      systemCronJobs = let
        backups = pkgs.writeScript "backups" ''
          #!${pkgs.stdenv.shell}

          ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v:
            ''
              touch ${varDir}/${k}.log
              ${pkgs.duply}/bin/duply ${config.secrets.location}/backup/${k}/ ${action} --force >> ${varDir}/${k}.log
            ''
          ) config.services.duplyBackup.profiles)}
        '';
      in
        [
          "0 2 * * * root ${backups}"
        ];

    };

    security.pki.certificateFiles = [
      (pkgs.fetchurl {
        url = "http://downloads.e.eriomem.net/eriomemca.pem";
        sha256 = "1ixx4c6j3m26j8dp9a3dkvxc80v1nr5aqgmawwgs06bskasqkvvh";
      })
    ];
  };
}
