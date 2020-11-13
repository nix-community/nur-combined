{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.duplicity;

  stateDirectory = "/var/lib/duplicity";

  filelistModule = { ... }: {
    options = {
      path = mkOption {
        type = types.str;
        example = "/home/foo";
      };

      include = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  jobModule = { name, ... }: {
    options = {
      frequency = mkOption {
        type = types.nullOr types.str;
        default = "daily";
        description = ''
          Run duplicity with the given frequency (see
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry> for the format).
          If null, do not run automatically.
        '';
      };

      fullInterval = mkOption {
        type = types.str;
        default = "1M";
        example = "1Y";
        description = "Run a full backup at this interval";
      };

      keepCount = mkOption {
        type = types.int;
        default = 3;
        description = "Number of full backups to keep";
      };

      numRetries = mkOption {
        type = types.int;
        default = 3;
      };

      srcDir = mkOption {
        type = types.str;
        default = "/";
      };

      includeFilelist = mkOption {
        type = with types; listOf (submodule filelistModule);
        default = [ ];
        example = literalExample ''
          [
            { path = "/home/foo/Backups"; include = false; }
            { path = "/home/foo/.ssh"; include = false; }
            { path = "/home/foo"; include = true; }
            { path = "**"; include = false; }
          ]
        '';
      };

      target = {
        secretsFile = mkOption { type = types.str; };

        url = mkOption {
          type = types.str;
          description = ''
            This is NOT shell-escaped to allow for interpolation of the password.
          '';
        };

        maxBlocksize = mkOption {
          type = types.ints.positive;
          default = 20480;
        };

        volsize = mkOption {
          type = types.ints.positive;
          default = 256;
          description = "In megabytes";
        };

        timeout = mkOption {
          type = types.ints.positive;
          default = 30;
          description = "Socket timeout for network operations";
        };
      };

      readWritePaths = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Filesystem paths that the preExec or postExec script needs read
          and write access to.
        '';
      };

      preExec = mkOption {
        type = types.lines;
        default = "";
        description = "Shell commands to run before each backup";
      };

      postExec = mkOption {
        type = types.lines;
        default = "";
        description = "Shell commands to run after each backup";
      };

      name = mkOption { type = types.str; };
    };

    config = { name = mkDefault name; };
  };

  jobUnitName = job: "duplicity-${job.name}";

  jobScript = job:
    let
      includeFilelist = concatMapStringsSep "\n"
        (entry: "${if entry.include then "+" else "-"} ${entry.path}")
        (job.includeFilelist ++ [{
          path = "**";
          include = false;
        }]);

      includeFile = pkgs.writeText "filelist" includeFilelist;

      helpFile = pkgs.writeText "help" ''
        Usage: ${jobUnitName job} command

        This is a wrapper for duplicity. Most options are configured in
        NixOS. Please make modifications in that configuration.

        Configuration of job:

        Key id:         ${cfg.gpg.keyId}
        Sign key id:    ${cfg.gpg.signKeyId}
        Full interval:  ${job.fullInterval}
        Keep count:     ${toString job.keepCount}
        Src dir:        ${job.srcDir}
        Max blocksize:  ${toString job.target.maxBlocksize}
        Volsize:        ${toString job.target.volsize}

        Include filelist:

        ${includeFilelist}

        Commands:

        run
            Run an incremental or full backup depending on if the full backup is
            older than the <full interval>. After that keep only the most recent
            <keep count> full backups.

        full [options]
            Perform a full backup.

        incr [options]
            Perform an incremental backup.

        verify [options]
            Verify integrity of the backup by downloading each file and checking
            both that it can restore the archive and that the signatures match.

        collection-status [options]
            Summarize the status of the backup repository by printing the chains
            and sets found, and the number of volumes in each.

        list-current-files [options]
            Lists the files contained in the most current backup or backup at
            time.

        restore <target_dir>
            You can restore the full monty or selected folders/files from a
            specific time.

        remove-older-than <time>
            Delete all backup sets older than the given time.

        remove-all-but-n-full <count>
            Keep the last <count> full backups and associated incremental sets.

        remove-all-inc-of-but-n-full <count>
            Delete incremental sets of all backups sets that are older than the
            <count>:th last full backup.

        cleanup
            Delete the extraneous duplicity files on the given backend.
      '';

      src = escapeShellArg job.srcDir;

    in pkgs.writeShellScriptBin (jobUnitName job) ''
      set -euo pipefail

      # Load secrets.
      . ${cfg.gpg.passphraseFile}
      . ${job.target.secretsFile}

      TARGET_URL=${job.target.url}

      # Export passphrase of the GPG key.
      export PASSPHRASE

      # Home needs to be set for GnuPG.
      export HOME=${stateDirectory}

      DUPLICITY="${cfg.package}/bin/duplicity \
        --archive-dir ${stateDirectory} \
        --encrypt-key ${cfg.gpg.keyId} \
        --sign-key ${cfg.gpg.signKeyId} \
        --num-retries ${toString job.numRetries} \
        --asynchronous-upload \
        --include-filelist ${includeFile} \
        --max-blocksize ${toString job.target.maxBlocksize} \
        --volsize ${toString job.target.volsize} \
        --timeout ${toString job.target.timeout}"

      case "''${1:-}" in
        full|incremental)
          $DUPLICITY "$@" ${src} "$TARGET_URL"
          ;;

        restore|verify)
          $DUPLICITY $1 "''${@:3}" "$TARGET_URL" "$2"
          ;;

        ${
          concatStringsSep "|" [
            "collection-status"
            "list-current-files"
            "cleanup"
            "remove-older-than"
            "remove-all-but-n-full"
            "remove-all-inc-of-but-n-full"
          ]
        })
          $DUPLICITY "$@" "$TARGET_URL"
          ;;

        run)
          ${job.preExec}

          # Run an incremental or full backup depending on if the full backup
          # is older than job.fullInterval.
          $DUPLICITY \
            --full-if-older-than ${toString job.fullInterval} \
            "''${@:2}" \
            ${src} "$TARGET_URL"

          # Keep only the last job.keepCount full backups.
          $DUPLICITY \
            remove-all-but-n-full ${toString job.keepCount} \
            --force \
            "''${@:2}" \
            "$TARGET_URL"

          ${job.postExec}
          ;;

        [-][-]help)
          ${cfg.package}/bin/duplicity --help
          ;;

        *)
          cat ${helpFile}
          ;;
      esac
    '';

in {
  options.services.duplicity = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable duplicity backups";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.duplicity;
    };

    gpg = {
      passphraseFile = mkOption {
        type = types.str;
        description = "Path to the file that contains the passphrase";
      };

      keyId = mkOption {
        type = types.str;
        description = "Key ID";
      };

      signKeyId = mkOption {
        type = types.str;
        default = cfg.gpg.keyId;
        description = "Sign key ID";
      };
    };

    jobs = mkOption {
      type = with types; attrsOf (submodule jobModule);
      default = { };
      description = "Duplicity jobs";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mapAttrsToList (_: jobScript) cfg.jobs;

    systemd = mkMerge (flip mapAttrsToList cfg.jobs (_: job:
      let
        name = jobUnitName job;
        localTarget = if hasPrefix "file://" job.target.url then
          removePrefix "file://" job.target.url
        else
          null;
      in {
        services.${name} = {
          description = "Duplicity backup for ${job.name}";

          serviceConfig = {
            ExecStart = "${jobScript job}/bin/${name} run";
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = "read-only";
            StateDirectory = baseNameOf stateDirectory;
            ReadWritePaths = job.readWritePaths
              ++ optional (localTarget != null) localTarget;
          };
        } // optionalAttrs (job.frequency != null) { startAt = job.frequency; };

        tmpfiles.rules =
          optional (localTarget != null) "d ${localTarget} 0700 root root -";
      }));
  };
}
