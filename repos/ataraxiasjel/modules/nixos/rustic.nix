{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with lib;

let
  # Type for a valid systemd unit option. Needed for correctly passing "timerConfig" to "systemd.timers"
  inherit (utils.systemdUtils.unitOptions) unitOption;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.rustic.backups = mkOption {
    description = lib.mdDoc ''
      Periodic backups to create with Rustic.
    '';
    type = types.attrsOf (
      types.submodule (
        { ... }:
        {
          options = {
            settings = mkOption {
              type = settingsFormat.type;
              default = { };
              description = lib.mdDoc "";
            };

            environmentFile = mkOption {
              type = with types; nullOr str;
              default = null;
              description = lib.mdDoc ''
                file containing the credentials to access the repository, in the
                format of an EnvironmentFile as described by systemd.exec(5)
              '';
            };

            extraEnvironment = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              example = lib.literalExpression ''
                {
                  http_proxy = "http://server:12345";
                }
              '';
              description = lib.mdDoc "Environment variables to pass to rustic.";
            };

            rcloneOptions = mkOption {
              type =
                with types;
                nullOr (
                  attrsOf (oneOf [
                    str
                    bool
                  ])
                );
              default = null;
              description = lib.mdDoc ''
                Options to pass to rclone to control its behavior.
                See <https://rclone.org/docs/#options> for
                available options. When specifying option names, strip the
                leading `--`. To set a flag such as
                `--drive-use-trash`, which does not take a value,
                set the value to the Boolean `true`.
              '';
              example = {
                bwlimit = "10M";
                drive-use-trash = "true";
              };
            };

            rcloneConfigFile = mkOption {
              type = with types; nullOr path;
              default = null;
              description = lib.mdDoc ''
                Path to the file containing rclone configuration. This file
                must contain configuration for the remote specified in this backup
                set and also must be readable by root. Options set in
                `rcloneConfig` will override those set in this
                file.
              '';
            };

            timerConfig = mkOption {
              type = types.attrsOf unitOption;
              default = {
                OnCalendar = "daily";
                Persistent = true;
              };
              description = lib.mdDoc ''
                When to run the backup. See {manpage}`systemd.timer(5)` for details.
              '';
              example = {
                OnCalendar = "00:05";
                RandomizedDelaySec = "5h";
                Persistent = true;
              };
            };

            user = mkOption {
              type = types.str;
              default = "root";
              description = lib.mdDoc ''
                As which user the backup should run.
              '';
              example = "postgresql";
            };

            extraBackupArgs = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc ''
                Extra arguments passed to rustic backup.
              '';
              example = [ "--exclude-file=/etc/nixos/rustic-ignore" ];
            };

            extraOptions = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc ''
                Extra extended options to be passed to the rustic --option flag.
              '';
              example = [ "sftp.command='ssh backup@192.168.1.100 -i /home/user/.ssh/id_rsa -s sftp'" ];
            };

            backup = mkOption {
              type = types.bool;
              default = true;
              description = lib.mdDoc ''
                Start backup.
              '';
            };

            prune = mkOption {
              type = types.bool;
              default = true;
              description = lib.mdDoc ''
                Start prune.
              '';
            };

            initialize = mkOption {
              type = types.bool;
              default = false;
              description = lib.mdDoc ''
                Create the repository if it doesn't exist.
              '';
            };

            initializeOpts = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc ''
                A list of options for 'rustic init'.
              '';
              example = [ "--set-version 2" ];
            };

            checkOpts = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc ''
                A list of options for 'rustic check', which is run after
                pruning.
              '';
              example = [ "--with-cache" ];
            };

            pruneOpts = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = lib.mdDoc ''
                A list of options for 'rustic prune', which is run before
                pruning.
              '';
              example = [ "--repack-cacheable-only=false" ];
            };

            backupCommandPrefix = mkOption {
              type = types.str;
              default = "";
              description = lib.mdDoc ''
                Prefix for backup command.
              '';
            };

            backupCommandSuffix = mkOption {
              type = types.str;
              default = "";
              description = lib.mdDoc ''
                Suffix for backup command.
              '';
            };

            backupPrepareCommand = mkOption {
              type = with types; nullOr str;
              default = null;
              description = lib.mdDoc ''
                A script that must run before starting the backup process.
              '';
            };

            backupCleanupCommand = mkOption {
              type = with types; nullOr str;
              default = null;
              description = lib.mdDoc ''
                A script that must run after finishing the backup process.
              '';
            };

            package = mkOption {
              type = types.package;
              default = pkgs.rustic;
              defaultText = literalExpression "pkgs.rustic";
              description = lib.mdDoc ''
                Rustic package to use.
              '';
            };

            createWrapper = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Whether to generate and add a script to the system path, that has the same environment variables set
                as the systemd service. This can be used to e.g. mount snapshots or perform other opterations, without
                having to manually specify most options.
              '';
            };
          };
        }
      )
    );
    default = { };
  };

  config = {
    systemd.services = mapAttrs' (
      name: backup:
      let
        profile = settingsFormat.generate "${name}.toml" backup.settings;
        extraOptions = concatMapStrings (arg: " -o ${arg}") backup.extraOptions;
        rusticCmd = "${backup.package}/bin/rustic -P ${lib.strings.removeSuffix ".toml" profile}${extraOptions}";
        # Helper functions for rclone remotes
        rcloneAttrToOpt = v: "RCLONE_" + toUpper (builtins.replaceStrings [ "-" ] [ "_" ] v);
        toRcloneVal = v: if lib.isBool v then lib.boolToString v else v;
      in
      nameValuePair "rustic-backups-${name}" (
        {
          environment =
            backup.extraEnvironment
            // {
              # not %C, because that wouldn't work in the wrapper script
              RUSTIC_CACHE_DIR = "/var/cache/rustic-backups-${name}";
            }
            // optionalAttrs (backup.rcloneConfigFile != null) { RCLONE_CONFIG = backup.rcloneConfigFile; }
            // optionalAttrs (backup.rcloneOptions != null) (
              mapAttrs' (
                name: value: nameValuePair (rcloneAttrToOpt name) (toRcloneVal value)
              ) backup.rcloneOptions
            );
          path = [
            config.programs.ssh.package
            pkgs.rclone
          ];
          restartIfChanged = false;
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          script = ''
            ${optionalString (backup.backup) ''
              ${backup.backupCommandPrefix} ${rusticCmd} backup ${concatStringsSep " " backup.extraBackupArgs} ${backup.backupCommandSuffix}
            ''}
            ${optionalString (backup.prune) ''
              ${rusticCmd} forget --prune ${concatStringsSep " " backup.pruneOpts}
              ${rusticCmd} check ${concatStringsSep " " backup.checkOpts}
            ''}
          '';
          serviceConfig = {
            Type = "oneshot";
            User = backup.user;
            RuntimeDirectory = "rustic-backups-${name}";
            CacheDirectory = "rustic-backups-${name}";
            CacheDirectoryMode = "0700";
            PrivateTmp = true;
          }
          // optionalAttrs (backup.environmentFile != null) { EnvironmentFile = backup.environmentFile; };
        }
        // optionalAttrs (backup.initialize || backup.backupPrepareCommand != null) {
          preStart = ''
            ${optionalString (backup.backupPrepareCommand != null) ''
              ${pkgs.writeScript "backupPrepareCommand" backup.backupPrepareCommand}
            ''}
            ${optionalString (backup.initialize) ''
              ${rusticCmd} init ${concatStringsSep " " backup.initializeOpts} || true
            ''}
          '';
        }
        // optionalAttrs (backup.backupCleanupCommand != null) {
          postStop = ''
            ${optionalString (backup.backupCleanupCommand != null) ''
              ${pkgs.writeScript "backupCleanupCommand" backup.backupCleanupCommand}
            ''}
          '';
        }
      )
    ) config.services.rustic.backups;
    systemd.timers = mapAttrs' (
      name: backup:
      nameValuePair "rustic-backups-${name}" {
        wantedBy = [ "timers.target" ];
        timerConfig = backup.timerConfig;
      }
    ) config.services.rustic.backups;

    # generate wrapper scripts, as described in the createWrapper option
    environment.systemPackages = lib.mapAttrsToList (
      name: backup:
      let
        profile = settingsFormat.generate "${name}.toml" backup.settings;
        extraOptions = concatMapStrings (arg: " -o ${arg}") backup.extraOptions;
        rusticCmd = "${backup.package}/bin/rustic -P ${lib.strings.removeSuffix ".toml" profile}${extraOptions}";
      in
      pkgs.writeShellScriptBin "rustic-${name}" ''
        set -a  # automatically export variables
        ${lib.optionalString (backup.environmentFile != null) "source ${backup.environmentFile}"}
        # set same environment variables as the systemd service
        ${lib.pipe config.systemd.services."rustic-backups-${name}".environment [
          (lib.filterAttrs (_: v: v != null))
          (lib.mapAttrsToList (n: v: "${n}=${v}"))
          (lib.concatStringsSep "\n")
        ]}

        exec ${rusticCmd} $@
      ''
    ) (lib.filterAttrs (_: v: v.createWrapper) config.services.rustic.backups);
  };
}
