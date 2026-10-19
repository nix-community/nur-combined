{
  config,
  lib,
  pkgs,
  ...
}:
let
  hl = config.homelab;
  cfg = hl.services.restic;

  # Services that declared what they need backed up via `data`.
  dataServices = lib.filterAttrs (
    _: svc: lib.isAttrs svc && (svc.enable or false) && (svc.data or null) != null
  ) hl.services;

  postgresServices = lib.attrNames (
    lib.filterAttrs (_: svc: svc.data.postgres or null != null) dataServices
  );

  # verb: the systemctl subcommand ("stop"/"start"); label: past-continuous
  # form for the log line ("Stopping"/"Starting").
  mkStopCmds =
    units: verb: label:
    lib.concatMapStringsSep "\n" (u: ''
      echo "${label} ${u} for backup..."
      systemctl ${verb} ${u} || echo "WARNING: failed to ${verb} ${u}"
    '') units;

  # Auto-generate a restic backup job from a service's `data` declaration.
  mkBackupJob =
    name: svc:
    let
      d = svc.data;
      hasSqlite = d.sqlite != null;
      hasPostgres = d.postgres != null;
      dumpDir = "/var/backup/restic-${name}";
      stopUnits = if d.stopUnits != [ ] then d.stopUnits else [ name ];

      prepareCommand = lib.concatStringsSep "\n" (
        lib.optional hasSqlite ''
          echo "Checkpointing sqlite WAL for ${name}..."
          ${pkgs.sqlite}/bin/sqlite3 "${d.sqlite}" "PRAGMA wal_checkpoint(TRUNCATE);" || true
        ''
        ++ lib.optional hasPostgres ''
          echo "Dumping PostgreSQL database ${d.postgres} for ${name}..."
          install -d -m 0700 -o postgres -g postgres ${dumpDir}
          ${pkgs.sudo}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/pg_dump ${d.postgres} > ${dumpDir}/dump.sql
        ''
        ++ lib.optional d.stopForBackup (mkStopCmds stopUnits "stop" "Stopping")
      );

      cleanupCommand = lib.concatStringsSep "\n" (
        lib.optional d.stopForBackup (mkStopCmds stopUnits "start" "Starting")
        ++ lib.optional hasPostgres "rm -rf ${dumpDir}"
      );

      paths =
        (lib.optional hasSqlite (builtins.dirOf d.sqlite)) ++ (lib.optional hasPostgres dumpDir) ++ d.files;
    in
    {
      inherit paths;
      inherit (d) exclude;
      inherit (cfg) repository;
      inherit (cfg) passwordFile;
      initialize = true;
      # Retention is enforced once for the whole repository by the shared
      # weekly prune below (see its comment for why per-service prune is
      # actively harmful on a repo this small).
      pruneOpts = [ ];
      extraBackupArgs = [
        "--tag service:${name}"
      ]
      ++ lib.optional hasSqlite "--tag type:sqlite"
      ++ lib.optional hasPostgres "--tag type:postgres";
      timerConfig = {
        OnCalendar = cfg.schedule;
        RandomizedDelaySec = "20m";
        Persistent = true;
      };
      backupPrepareCommand = lib.mkIf (prepareCommand != "") prepareCommand;
      backupCleanupCommand = lib.mkIf (cleanupCommand != "") cleanupCommand;
    }
    // lib.optionalAttrs (cfg.environmentFile != null) {
      inherit (cfg) environmentFile;
    };

  backupCli = pkgs.writeShellApplication {
    name = "homelab-backup";
    runtimeInputs = [
      pkgs.restic
      pkgs.jq
      pkgs.gum
    ];
    text = ''
      # Auto-elevate to root if needed (restic repo/password files and
      # systemctl restarts of service units require it).
      if [ "$(id -u)" -ne 0 ]; then
        exec sudo "$0" "$@"
      fi

      restic_cmd() {
        restic \
          --repo ${lib.escapeShellArg cfg.repository} \
          --password-file ${lib.escapeShellArg cfg.passwordFile} \
          "$@"
      }

      ${lib.optionalString (cfg.environmentFile != null) ''
        set -a
        # shellcheck disable=SC1091
        source ${lib.escapeShellArg cfg.environmentFile}
        set +a
      ''}

      SERVICES="${lib.concatStringsSep " " (lib.attrNames dataServices)}"
      POSTGRES_SERVICES="${lib.concatStringsSep " " postgresServices}"

      is_postgres_service() {
        for p in $POSTGRES_SERVICES; do
          [ "$p" = "$1" ] && return 0
        done
        return 1
      }

      postgres_restore_reminder() {
        gum style --foreground 214 "  $1 stores its data in PostgreSQL: the restored dump is at"
        gum style --foreground 214 "  /var/backup/restic-$1/dump.sql -- load it manually, e.g.:"
        gum style --foreground 214 "    sudo -u postgres psql <dbname> < /var/backup/restic-$1/dump.sql"
      }

      cmd_status() {
        gum style --bold --foreground 212 "Backup Status"
        echo
        for svc in $SERVICES; do
          latest=$(restic_cmd snapshots --tag "service:$svc" --json --latest 1 2>/dev/null | jq -r '.[0] // empty')
          if [ -n "$latest" ]; then
            time=$(echo "$latest" | jq -r '.time' | cut -d'T' -f1)
            hostname=$(echo "$latest" | jq -r '.hostname')
            gum style --foreground 35 "check $svc"
            gum style --foreground 117 "    Last backup: $time on $hostname"
          else
            gum style --foreground 214 "! $svc"
            gum style --foreground 117 "    No backups found"
          fi
        done
      }

      cmd_list() {
        gum style --bold --foreground 212 "List Snapshots"
        echo
        svc=$(echo "$SERVICES" | tr ' ' '\n' | gum choose --header "Select service:")
        if [ -z "$svc" ]; then
          gum style --foreground 196 "No service selected"
          exit 1
        fi
        gum style --foreground 117 "Snapshots for $svc:"
        echo
        restic_cmd snapshots --tag "service:$svc" --compact
      }

      run_backup() {
        local svc_name=$1
        if systemctl is-active --quiet "restic-backups-$svc_name.service"; then
          gum style --foreground 214 "! $svc_name backup already in progress"
          gum style --foreground 117 "  Use: journalctl -u restic-backups-$svc_name.service -f"
          return 1
        fi

        gum style --foreground 117 "Backing up $svc_name..."
        journalctl -u "restic-backups-$svc_name.service" -f -n 0 --output=cat &
        journal_pid=$!
        sleep 0.2

        systemctl start "restic-backups-$svc_name.service"
        while systemctl is-active --quiet "restic-backups-$svc_name.service"; do
          sleep 1
        done
        kill "$journal_pid" 2>/dev/null || true

        if systemctl is-failed --quiet "restic-backups-$svc_name.service"; then
          gum style --foreground 196 "x $svc_name failed"
          return 1
        else
          gum style --foreground 35 "check $svc_name complete"
          return 0
        fi
      }

      cmd_backup() {
        gum style --bold --foreground 212 "Manual Backup"
        echo
        svc=$(echo "all $SERVICES" | tr ' ' '\n' | gum choose --header "Select service to backup:")
        if [ -z "$svc" ]; then
          gum style --foreground 196 "No service selected"
          exit 1
        fi

        if [ "$svc" = "all" ]; then
          for s in $SERVICES; do
            run_backup "$s" || true
            echo
          done
        else
          run_backup "$svc"
        fi
      }

      cmd_restore() {
        gum style --bold --foreground 212 "Restore Wizard"
        echo
        svc=$(echo "$SERVICES" | tr ' ' '\n' | gum choose --header "Select service to restore:")
        if [ -z "$svc" ]; then
          gum style --foreground 196 "No service selected"
          exit 1
        fi

        gum style --foreground 117 "Fetching snapshots for $svc..."
        snapshots=$(restic_cmd snapshots --tag "service:$svc" --json 2>/dev/null)
        if [ "$(echo "$snapshots" | jq 'length')" = "0" ]; then
          gum style --foreground 196 "No snapshots found for $svc"
          exit 1
        fi

        snapshot_list=$(echo "$snapshots" | jq -r '.[] | "\(.short_id) - \(.time | split("T")[0]) - \(.paths | join(", "))"')
        selected=$(echo "$snapshot_list" | gum choose --header "Select snapshot:")
        snapshot_id=$(echo "$selected" | cut -d' ' -f1)
        if [ -z "$snapshot_id" ]; then
          gum style --foreground 196 "No snapshot selected"
          exit 1
        fi

        restore_mode=$(gum choose --header "Restore mode:" "Inspect (restore to /tmp)" "In-place (DANGEROUS)")
        case "$restore_mode" in
          "Inspect"*)
            target="/tmp/restore-$svc-$snapshot_id"
            mkdir -p "$target"
            gum style --foreground 117 "Restoring to $target..."
            restic_cmd restore "$snapshot_id" --target "$target"
            gum style --foreground 35 "check Restored to $target"
            gum style --foreground 117 "  Inspect files, then copy what you need"
            ;;
          "In-place"*)
            gum style --foreground 196 --bold "WARNING: This will overwrite existing data!"
            echo
            if ! gum confirm "Stop $svc and restore data?"; then
              gum style --foreground 214 "Restore cancelled"
              exit 0
            fi
            gum style --foreground 117 "Stopping $svc..."
            systemctl stop "$svc" 2>/dev/null || true
            gum style --foreground 117 "Restoring snapshot $snapshot_id..."
            restic_cmd restore "$snapshot_id" --target /
            if is_postgres_service "$svc"; then
              postgres_restore_reminder "$svc"
            else
              gum style --foreground 117 "Starting $svc..."
              systemctl start "$svc" 2>/dev/null || true
            fi
            gum style --foreground 35 "check Restore complete"
            ;;
        esac
      }

      cmd_dr() {
        gum style --bold --foreground 196 "DISASTER RECOVERY MODE"
        echo
        gum style --foreground 214 "This will restore the LATEST snapshot of every service."
        gum style --foreground 214 "Only use this on a fresh install or when data is already lost."
        echo
        if ! gum confirm "Continue with full disaster recovery?"; then
          gum style --foreground 117 "Cancelled"
          exit 0
        fi

        for svc in $SERVICES; do
          gum style --foreground 212 "Restoring $svc..."
          snapshot_id=$(restic_cmd snapshots --tag "service:$svc" --json --latest 1 2>/dev/null | jq -r '.[0].short_id // empty')
          if [ -z "$snapshot_id" ]; then
            gum style --foreground 214 "  ! No snapshots found, skipping"
            continue
          fi
          systemctl stop "$svc" 2>/dev/null || true
          restic_cmd restore "$snapshot_id" --target /
          if is_postgres_service "$svc"; then
            postgres_restore_reminder "$svc"
          else
            systemctl start "$svc" 2>/dev/null || true
          fi
          gum style --foreground 35 "  check Restored from $snapshot_id"
        done

        echo
        gum style --bold --foreground 35 "check Disaster recovery complete"
      }

      cmd_menu() {
        gum style --bold --foreground 212 "Homelab Backup"
        echo
        action=$(gum choose \
          "Status - Show backup status" \
          "List - Browse snapshots" \
          "Backup - Trigger manual backup" \
          "Restore - Restore from backup" \
          "DR - Disaster recovery mode")
        case "$action" in
          Status*) cmd_status ;;
          List*) cmd_list ;;
          Backup*) cmd_backup ;;
          Restore*) cmd_restore ;;
          DR*) cmd_dr ;;
          *) exit 0 ;;
        esac
      }

      case "''${1:-}" in
        status) cmd_status ;;
        list) cmd_list ;;
        backup) cmd_backup ;;
        restore) cmd_restore ;;
        dr|disaster-recovery) cmd_dr ;;
        --help|-h)
          echo "Usage: homelab-backup [command]"
          echo
          echo "Commands:"
          echo "  status   Show backup status for all services"
          echo "  list     List snapshots"
          echo "  backup   Trigger manual backup"
          echo "  restore  Interactive restore wizard"
          echo "  dr       Disaster recovery mode"
          echo
          echo "Run without arguments for interactive menu."
          ;;
        "") cmd_menu ;;
        *)
          gum style --foreground 196 "Unknown command: $1"
          exit 1
          ;;
      esac
    '';
  };
in
{
  options.homelab.services.restic = {
    enable = lib.mkEnableOption "Restic backups for services that declare a `data` option";
    repository = lib.mkOption {
      type = lib.types.str;
      description = "Restic repository URL (e.g. s3:s3.amazonaws.com/bucket, /mnt/backup, sftp:user@host:/path)";
    };
    passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "File containing the restic repository encryption password";
    };
    # For cloud backends: file with provider creds, e.g.
    #   AWS_ACCESS_KEY_ID=...
    #   AWS_SECRET_ACCESS_KEY=...
    #   B2_ACCOUNT_ID=...  etc.
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File with cloud backend credentials";
    };
    schedule = lib.mkOption {
      type = lib.types.str;
      default = "03:30";
      description = "systemd OnCalendar schedule for each service's backup job";
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups = lib.mapAttrs mkBackupJob dataServices;

    systemd.services =
      (lib.mapAttrs' (
        name: _:
        lib.nameValuePair "restic-backups-${name}" {
          unitConfig.OnFailure = lib.mkIf (
            hl.notifications.ntfySecretsFile != null
          ) "notify-failure@%n.service";
        }
      ) dataServices)
      // {
        # ONE weekly prune for the whole repository.
        #
        # Per-service prune (`forget --prune --tag service:X`) only uses the
        # tag to pick which *snapshots to forget* -- the prune that follows
        # still walks and repacks the entire repository. So N services would
        # mean N full-repo repacks per week, which blows through B2's Class B
        # transaction cap fast and can wedge a prune mid-run, leaving an
        # exclusive lock that blocks every backup until someone notices.
        #
        # `--group-by host,tags` applies the retention policy independently
        # to each service's tag group, so per-service retention is preserved
        # exactly, but the repository is only repacked once.
        restic-prune = {
          description = "Weekly restic forget/prune for all services";
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            # A prune that hangs holds the repo's exclusive lock and blocks
            # every backup until someone notices. Bound it; restic releases
            # its lock on SIGTERM.
            TimeoutStartSec = "6h";
          };
          script = ''
            set -euo pipefail

            restic() {
              ${pkgs.restic}/bin/restic \
                --repo ${lib.escapeShellArg cfg.repository} \
                --password-file ${lib.escapeShellArg cfg.passwordFile} \
                "$@"
            }

            # Clear locks whose owning process is gone (e.g. a prune killed
            # mid-run). This only removes *stale* locks, never a live one.
            restic unlock || true

            restic forget --prune --verbose \
              --group-by host,tags \
              --keep-last 3 --keep-daily 7 --keep-weekly 5 --keep-monthly 12
          '';
          unitConfig.OnFailure = lib.mkIf (
            hl.notifications.ntfySecretsFile != null
          ) "notify-failure@%n.service";
        };

        # `restic check` verifies repo structure/index integrity every run,
        # plus actually reads back a rotating subset of pack data to catch
        # silent corruption -- reading 100% weekly would mean re-downloading
        # the whole repo from B2 every week, so a subset is checked each run
        # and full coverage accumulates over several weeks instead.
        restic-check = {
          description = "Weekly restic repository integrity check";
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
            TimeoutStartSec = "6h";
          };
          script = ''
            set -euo pipefail

            restic() {
              ${pkgs.restic}/bin/restic \
                --repo ${lib.escapeShellArg cfg.repository} \
                --password-file ${lib.escapeShellArg cfg.passwordFile} \
                "$@"
            }

            restic unlock || true
            restic check --read-data-subset=5%
          '';
          unitConfig.OnFailure = lib.mkIf (
            hl.notifications.ntfySecretsFile != null
          ) "notify-failure@%n.service";
        };
      };

    systemd.timers.restic-prune = {
      description = "Weekly restic prune (Sun)";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Sun *-*-* 05:00:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };

    systemd.timers.restic-check = {
      description = "Weekly restic check (Wed)";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Wed *-*-* 05:00:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };

    environment.systemPackages = [
      pkgs.restic
      pkgs.sqlite
      backupCli
    ];
  };
}
