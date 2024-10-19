{
  pkgs,
  config,
  lib,
  utils,
  ...
}:
let
  cfg = config.services.rustic;
  inherit (lib)
    mkOption
    listToAttrs
    foldl'
    types
    removeSuffix
    mkPackageOption
    attrNames
    attrValues
    mkIf
    mapAttrs'
    filterAttrs
    nameValuePair
    ;
  inherit (utils.systemdUtils.unitOptions) unitOption;

in
{
  disabledModules = [ "services/backup/rustic-rs.nix" ];
  options.services.rustic = {
    backups = mkOption {
      description = "list of rustic instance";
      type = types.attrsOf (
        types.submodule {
          options = {
            package = mkPackageOption pkgs "rustic" { };
            profiles = mkOption {
              type = with types; listOf str;
              default = [ ];
              description = "profiles file path";
            };
            timerConfig = mkOption {
              type = types.nullOr (types.attrsOf unitOption);
              default = {
                OnCalendar = "daily";
                Persistent = true;
              };
              description = lib.mdDoc ''
                When to run the backup. See {manpage}`systemd.timer(5)` for
                details. If null no timer is created and the backup will only
                run when explicitly started.
              '';
              example = {
                OnCalendar = "00:05";
                RandomizedDelaySec = "5h";
                Persistent = true;
              };
            };
          };
        }
      );
      default = { };
    };
  };
  config = mkIf (cfg.backups != [ ]) {
    environment.systemPackages = [ pkgs.rustic ];
    environment.etc = listToAttrs (
      map (n: nameValuePair ("rustic/" + removeSuffix ".toml" (baseNameOf n)) { source = n; }) (
        foldl' (acc: i: acc ++ i.profiles) [ ] (attrValues cfg.backups)
      )
    );

    systemd.services = mapAttrs' (
      name: opts:
      nameValuePair "rustic-backups-${name}" {
        after = [
          "network-online.target"
          "nss-lookup.target"
        ];
        wants = [
          "network-online.target"
          "nss-lookup.target"
        ];
        restartIfChanged = false;
        description = "rustic ${name} backup";
        serviceConfig = {
          Type = "oneshot";
          RuntimeDirectory = "rustic-backups-${name}";
          CacheDirectory = "rustic-backups-${name}";
          CacheDirectoryMode = "0700";
          PrivateTmp = true;
          ExecStart =
            let
              profileArgs = lib.concatStringsSep " " (
                map (i: "-P ${removeSuffix ".toml" (baseNameOf i)}") (opts.profiles)
              );
              baseCmd = (lib.getExe' opts.package "rustic") + " " + profileArgs;
            in
            map (n: baseCmd + " " + n) [
              "backup"
              "check"
            ];
        };
      }
    ) cfg.backups;

    systemd.timers = mapAttrs' (
      name: backup:
      nameValuePair "rustic-backups-${name}" {
        wantedBy = [ "timers.target" ];
        timerConfig = backup.timerConfig;
      }
    ) (filterAttrs (_: backup: backup.timerConfig != null) cfg.backups);
  };
}
