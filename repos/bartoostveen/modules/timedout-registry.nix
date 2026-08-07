{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkPackageOption
    mkEnableOption
    mkOption
    getExe
    types
    mkIf
    mkDefault
    pipe
    mapAttrsRecursive
    optionalAttrs
    isList
    concatStringsSep
    isBool
    boolToString
    collect
    isString
    ;

  inherit (types)
    submodule
    attrs
    attrsOf
    str
    path
    ;

  cfg = config.services.timedout-registry;

  args = pipe cfg.settings [
    (mapAttrsRecursive (
      path: value:
      optionalAttrs (value != null) {
        name = concatStringsSep "-" path;
        value =
          if isList value then
            concatStringsSep "," value
          else if isBool value then
            boolToString value
          else
            toString value;
      }
    ))
    (collect (x: isString x.name or false && isString x.value or false))
    (map ({ name, value }: "-${name}=\"${value}\""))
    (concatStringsSep " ")
  ];

  entriesFormat = pkgs.formats.json { };
  entriesJson = entriesFormat.generate "timedout-registry-entries.json" cfg.entries;
in
{
  options.services.timedout-registry = {
    enable = mkEnableOption "timedout-registry: A tiny (0 dependency) Go server that acts as a registry for Golang packages";
    package = mkPackageOption pkgs "timedout-registry" { };
    settings = mkOption {
      description = "Settings for timedout-registry";
      type = submodule {
        freeformType = attrs;
        options = {
          listen = mkOption {
            description = "Address to listen on";
            type = str;
            default = "127.0.0.1:8080";
            example = "0.0.0.0:12345";
          };
          entries = mkOption {
            description = "Path to entries JSON file, setting this overrides {option}`services.timedout-registry.entries`";
            type = path;
            example = "/path/to/entries.json";
          };
        };
      };
    };
    entries = mkOption {
      description = "Entries for the registry. Setting {option}`services.timedout-registry.settings.entries` instead overrides this option";
      type = attrsOf (submodule {
        freeformType = attrs;
        options = {
          import_path = mkOption {
            description = "Import path which gets resolved by `go get`";
            type = str;
            example = "go.example.com/example_slug";
          };
          repo_url = mkOption {
            description = "URL which this gets resolved into";
            type = str;
            example = "https://git.example.com/example_user/example_repo";
          };
        };
      });
      default = { };
      example = {
        example_slug = {
          import_path = "go.example.com/example_slug";
          repo_url = "https://git.example.com/example_user/example_repo";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.timedout-registry.settings.entries = mkDefault "${entriesJson}";

    systemd.services.timedout-registry = {
      description = "timedout-registry: A tiny (0 dependency) Go server that acts as a registry for Golang packages.";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "30s";
        DynamicUser = true;
        UMask = "0027";
        ExecStart = "${getExe cfg.package} ${args}";
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        PrivateUsers = true;
        ProtectClock = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
