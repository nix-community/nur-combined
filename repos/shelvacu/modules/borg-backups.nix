{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  e = lib.escapeShellArg;
  cfg = config.vacu.borgBackups;
  outerConfig = config;
  backupModule =
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.strMatching ''[a-zA-Z0-9_-]+'';
          default = name;
        };
        target = mkOption {
          type = types.attrTag {
            btrfs = mkOption {
              type = types.submodule {
                options = {
                  temporarySubvolume = mkOption {
                    description = "must be a mounted btrfs subvolume, used to store snapshots temporarily";
                    type = types.path;
                  };
                  subvolume = mkOption {
                    description = "must be a mounted btrfs subvolume. The subvol that contains the stuff to be backed up";
                    type = types.path;
                  };
                  pathInSubvolume = mkOption {
                    type = types.strMatching ''|[^/].*''; # not starting with a /
                    default = "";
                  };
                };
              };
            };
            zfs = mkOption {
              type = types.submodule {
                options = {
                  datasetPath = mkOption { type = types.path; };
                  pathInDataset = mkOption {
                    type = types.strMatching ''|[^/].*''; # not starting with a /
                    default = "";
                  };
                };
              };
            };
          };
        };
      };
      config = {
        fileSystemType = lib.mkDefault outerConfig.fileSystems.${config.fileSystem}.fsType;
      };
    };
  eachBackup =
    f:
    lib.mapAttrs' (
      backupCfg: lib.nameValuePair "borg-backup-${backupCfg.name}" (f backupCfg)
    ) cfg.backups;
in
{
  options.vacu.borgBackups = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    package = mkOption {
      type = types.pkg;
      default = pkgs.borgbackup;
    };
    backups = mkOption {
      type = types.attrsOf (types.submodule backupModule);
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.borg-backup = {
      isSystemUser = true;
      group = "borg-backup";
    };
    users.groups.borg-backup = { };

    systemd.targets."borg-backups".wantedBy = [ "multi-user.target" ];
    systemd.timers = eachBackup (backupCfg: { });
    systemd.services = eachBackup (
      backupCfg:
      let
        # can't use systemd.services.*.preStart because this needs to run as root (be prepended with + in the ExecStartPre line)
        preScript = pkgs.writeShellApplication {
          name = "borg-backup-${backupCfg.name}-pre-start-root";
          text =
            if backupCfg.target ? btrfs then
              ''
                function assert_btrfs_subvol() {
                  if [[ $# != 1 ]]; then
                    exit 2
                  fi
                  [[ -d $1 ]] || return 1
                  declare fs
                  fs="$(stat -f --format="%T" "$1")" || exit 3
                  [[ $fs == btrfs ]] || return 1
                  declare inode
                  inode="$(stat --format="%i" "$1")" || exit 4
                  case "$inode" in
                    2|256)
                      return 0
                      ;;
                    *)
                      echo "$1 is not a btrfs subvolume" >&2
                      exit 1
                      ;;
                  esac
                }
                tempSubvol=${e backupCfg.target.btrfs.temporarySubvolume}
                targetSubvol=${e backupCfg.target.btrfs.subvolume}
                targetPathInSubvol=${e backupCfg.target.btrfs.pathInSubvolume}
                assert_btrfs_subvol "$tempSubvol"
                assert_btrfs_subvol "$targetSubvol"
                declare snapName
                snapName="borg-backup-"${e backupCfg.name}"-snapshot-$(date +%s)"
                # printf "%s" "$snapName" > "$CACHE_DIRECTORY/btrfsSnapName.txt"
                ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r "$targetSubvol" "$tempSubvol/$snapName"
                mkdir "$CACHE_DIRECTORY/snapshot_mount"
                mount --rbind -o ro "$tempSubvol/$snapName/$targetPathInSubvol" "$CACHE_DIRECTORY/snapshot_mount"
              ''
            else if backupCfg.target ? zfs then
              ''
                datasetPath=${e backupCfg.target.zfs.datasetPath}
                pathInDataset=${e backupCfg.target.zfs.pathInDataset}
                declare ID= TARGET= FSTYPE= FSROOT= SOURCE=
                eval "$(${pkgs.util-linuxMinimal}/bin/findmnt --kernel --target "$datasetPath" --shell --pairs --output ID,TARGET,FSTYPE,SOURCE,FSROOT)"
                declare -p datasetPath pathInDataset ID TARGET FSTYPE FSROOT SOURCE
                if [[ $TARGET != "$datasetPath" ]]; then
                  echo "err: $datasetPath is not a mountpoint" >&2
                  exit 1
                fi
                if [[ $FSTYPE != zfs ]]; then
                  echo "err: $datasetPath is not a zfs filesystem" >&2
                  exit 1
                fi
                pool="''${SOURCE%"[$FSROOT]"}"
                fsID="$ID"
                declare ID=
                eval "$(${pkgs.util-linuxMinimal}/bin/findmnt --kernel --target "$datasetPath/$pathInDataset" --shell --pairs --output ID)"
                if [[ $fsID != "$ID" ]]; then
                  echo "$datasetPath/$pathInDataset is a different filesystem :(" >&2
                  exit 1
                fi
                declare snapName
                snapName="borg-backup-"${e backupCfg.name}"-snapshot-$(date +%s)"
                snapFullName="$pool@$snapName"
                ${pkgs.zfs}/bin/zfs snapshot "$snapFullName"
                mkdir "$CACHE_DIRECTORY/snapshot_mount"
                printf "%s" "$snapName" > "$CACHE_DIRECTORY/zfsSnapName.txt"
                mount --rbind -o ro "$datasetPath/.zfs/snapshot/$snapName/$pathInDataset" "$CACHE_DIRECTORY/snapshot_mount"
              ''
            else
              throw "huh?";
        };
        postScript = pkgs.writeShellApplication {
          name = "borg-backup-${backupCfg.name}-post-start-root";
          text =
            if backupCfg.target ? btrfs then
              ''
                ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$CACHE_DIRECTORY/snapshot_mount"
                umount "$CACHE_DIRECTORY/snapshot_mount" || true
              ''
            else if backupCfg.target ? zfs then
              ''
                umount "$CACHE_DIRECTORY/snapshot_mount"
                ${pkgs.zfs}/bin/zfs destroy "$(<"$CACHE_DIRECTORY/zfsSnapName.txt")"
              ''
            else
              throw "huh?";
        };
      in
      {
        script = ''
          # makes a date like 2025-04-15_21-24-29_UTC
          dashed_date="$(date -u '+%F_%H-%M-%S_%Z')"
          archive_name="auto-backup--$HOSTNAME--${backupCfg.name}--$dashed_date"
          export BORG_PASSPHRASE="$(cat ${lib.escapeShellArg cfg.keyPath})"
          export BORG_REMOTE_PATH="borg14"
          export BORG_RSH="ssh -i $STATE_DIRECTORY/id_ed25519"
          export BORG_REPO=${lib.escapeShellArg cfg.repo}
          export BORG_CACHE_DIR="$CACHE_DIRECTORY/borg"
          export BORG_CONFIG_DIR="$STATE_DIRECTORY/borg"
          cmd=(
            ${pkgs.borg-backup}/bin/borg
            create
            --show-rc
            --verbose
            --show-version
            --stats
            --atime
            "::$archive_name"
            "$CACHE_DIRECTORY/snapshot_mount"
          )
          "''${cmd[@]}"
        '';
        enableStrictShellChecks = true;
        serviceConfig = {
          User = "borg-backup";
          Group = "borg-backup";
          ExecStartPre = "+${preScript}";
          ExecStartPost = "+${postScript}";

          StateDirectory = "borg-backup-${backupCfg.name}";
          StateDirectoryMode = "0700";
          CacheDirectory = "borg-backup-${backupCfg.name}";
          CacheDirectoryMode = "0700";
        };
      }
    );
  };
}
