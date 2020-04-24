{ lib, pkgs, config, ... }:
let
  partModule = lib.types.submodule {
    options = {
      remote_folder = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to backup
          '';
      };
      exclude_from = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        description = ''
          Paths to exclude from the backup
          '';
      };
      files_from = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        description = ''
          Paths to take for the backup
          (if empty: whole folder minus exclude_from)
          '';
      };
      args = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          additional arguments for rsync
          '';
      };
    };
  };
  profileModule = lib.types.submodule {
    options = {
      keep = lib.mkOption {
        type = lib.types.int;
        default = 7;
        description = ''
          Number of backups to keep
          '';
      };
      login = lib.mkOption {
        type = lib.types.str;
        description = ''
          login to connect to
          '';
      };
      host = lib.mkOption {
        type = lib.types.str;
        description = ''
          host to connect to
          '';
      };
      port = lib.mkOption {
        type = lib.types.str;
        default = "22";
        description = ''
          port to connect to
          '';
      };
      host_key = lib.mkOption {
        type = lib.types.str;
        description = ''
          Host key to use as known host
          '';
      };
      host_key_type = lib.mkOption {
        type = lib.types.str;
        description = ''
          Host key type
          '';
      };
      parts = lib.mkOption {
        type = lib.types.attrsOf partModule;
        description = ''
          folders to backup in the host
          '';
      };
    };
  };
  cfg = config.services.rsyncBackup;

  ssh_key = config.secrets.fullPaths."rsync_backup/identity";

  backup_head = ''
    #!${pkgs.stdenv.shell}
    EXCL_FROM=`mktemp`
    FILES_FROM=`mktemp`
    TMP_STDERR=`mktemp`

    on_exit() {
      if [ -s "$TMP_STDERR" ]; then
        cat "$TMP_STDERR"
      fi
      rm -f $TMP_STDERR $EXCL_FROM $FILES_FROM
    }

    trap "on_exit" EXIT

    exec 2> "$TMP_STDERR"
    exec < /dev/null

    set -e
    '';

  backup_profile = name: profile: builtins.concatStringsSep "\n" (
    [(backup_profile_head name profile)]
    ++ lib.mapAttrsToList (backup_part name) profile.parts
    ++ [(backup_profile_tail name profile)]);

  backup_profile_head = name: profile: ''
      ##### ${name} #####
      PORT="${profile.port}"
      DEST="${profile.login}@${profile.host}"
      BASE="${cfg.mountpoint}/${name}"
      OLD_BAK_BASE=$BASE/older/j
      BAK_BASE=''${OLD_BAK_BASE}0
      RSYNC_OUTPUT=$BASE/rsync_output
      NBR=${builtins.toString profile.keep}

      if ! ssh \
          -o PreferredAuthentications=publickey \
          -o StrictHostKeyChecking=yes \
          -o ClearAllForwardings=yes \
          -o UserKnownHostsFile=/dev/null \
          -o CheckHostIP=no \
          -p $PORT \
          -i ${ssh_key} \
          $DEST backup; then
        echo "Fichier de verrouillage backup sur $DEST ou impossible de se connecter" >&2
        skip=$DEST
      fi

      rm -rf ''${OLD_BAK_BASE}''${NBR}
      for j in `seq -w $(($NBR-1)) -1 0`; do
        [ ! -d ''${OLD_BAK_BASE}$j ] && continue
        mv ''${OLD_BAK_BASE}$j ''${OLD_BAK_BASE}$(($j+1))
      done
      mkdir $BAK_BASE
      mv $RSYNC_OUTPUT $BAK_BASE
      mkdir $RSYNC_OUTPUT

      if [ "$skip" != "$DEST" ]; then
    '';

    backup_profile_tail = name: profile: ''
        ssh -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -i ${ssh_key} -p $PORT $DEST sh -c "date > .cache/last_backup"
      fi # [ "$skip" != "$DEST" ]
      ##### End ${name} #####
    '';

    backup_part = profile_name: part_name: part: ''
      ### ${profile_name} ${part_name} ###
      LOCAL="${part_name}"
      REMOTE="${part.remote_folder}"

      if [ ! -d "$BASE/$LOCAL" ]; then
        mkdir $BASE/$LOCAL
      fi
      cd $BASE/$LOCAL
      cat > $EXCL_FROM <<EOF
      ${builtins.concatStringsSep "\n" part.exclude_from}
      EOF
      cat > $FILES_FROM <<EOF
      ${builtins.concatStringsSep "\n" part.files_from}
      EOF

      OUT=$RSYNC_OUTPUT/$LOCAL
      ${pkgs.rsync}/bin/rsync --new-compress -XAavbr --fake-super -e "ssh -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -i ${ssh_key} -p $PORT" --numeric-ids --delete \
        --backup-dir=$BAK_BASE/$LOCAL \${
        lib.optionalString (part.args != null) "\n  ${part.args} \\"}${
        lib.optionalString (builtins.length part.exclude_from > 0) "\n  --exclude-from=$EXCL_FROM \\"}${
        lib.optionalString (builtins.length part.files_from > 0) "\n  --files-from=$FILES_FROM \\"}
        $DEST:$REMOTE . > $OUT || true
      ### End ${profile_name} ${part_name} ###
    '';
in
{
  options.services.rsyncBackup = {
    mountpoint = lib.mkOption {
      type = lib.types.path;
      description = "Path to the base folder for backups";
    };
    profiles = lib.mkOption {
      type = lib.types.attrsOf profileModule;
      default = {};
      description = ''
        Profiles to backup
        '';
    };
    ssh_key_public = lib.mkOption {
      type = lib.types.str;
      description = "Public key for the backup";
    };
    ssh_key_private = lib.mkOption {
      type = lib.types.str;
      description = "Private key for the backup";
    };
  };

  config = lib.mkIf (builtins.length (builtins.attrNames cfg.profiles) > 0) {
    # FIXME: monitoring to check that backup is less than 14h old
    users.users.backup = {
      isSystemUser = true;
      uid = config.ids.uids.backup;
      group = "backup";
      extraGroups = [ "keys" ];
    };

    users.groups.backup = {
      gid = config.ids.gids.backup;
    };

    services.cron.systemCronJobs = let
      backup = pkgs.writeScript "backup.sh" (builtins.concatStringsSep "\n" ([
        backup_head
      ] ++ lib.mapAttrsToList backup_profile cfg.profiles));
    in [
      ''
        25 3,15 * * * backup ${backup}
        ''
    ];

    programs.ssh.knownHosts = lib.attrsets.mapAttrs' (name: profile: lib.attrsets.nameValuePair name {
      hostNames = [ profile.host ];
      publicKey = "${profile.host_key_type} ${profile.host_key}";
    }) cfg.profiles;

    system.activationScripts.rsyncBackup = {
      deps = [ "users" ];
      text = builtins.concatStringsSep "\n" (map (v: ''
        install -m 0700 -o backup -g backup -d ${cfg.mountpoint}/${v} ${cfg.mountpoint}/${v}/older ${cfg.mountpoint}/${v}/rsync_output
        '') (builtins.attrNames cfg.profiles)
        );
    };

    secrets.keys = [
      {
        dest = "rsync_backup/identity";
        user = "backup";
        group = "backup";
        permissions = "0400";
        text = cfg.ssh_key_private;
      }
      {
        dest = "rsync_backup/identity.pub";
        user = "backup";
        group = "backup";
        permissions = "0444";
        text = cfg.ssh_key_public;
      }
    ];
  };
}
