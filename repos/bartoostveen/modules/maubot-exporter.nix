{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    mkDefault
    types
    getExe
    optional
    pipe
    mapAttrsRecursive
    optionalAttrs
    toUpper
    concatStringsSep
    isList
    isBool
    boolToString
    collect
    isString
    listToAttrs
    ;

  inherit (types)
    bool
    nullOr
    str
    submodule
    attrsOf
    port
    path
    ;

  cfg = config.services.maubot-exporter;

  environment = pipe cfg.settings [
    (mapAttrsRecursive (
      path: value:
      optionalAttrs (value != null) {
        name = toUpper "MAUBOT_${concatStringsSep "_" path}";
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
    listToAttrs
  ];
in
{
  options.services.maubot-exporter = {
    enable = mkEnableOption "maubot-exporter";
    package = mkPackageOption pkgs "maubot-exporter" { };
    local = mkOption {
      description = "whether to depend on the local maubot instance";
      type = bool;
      example = false;
    };
    listen = mkOption {
      description = "Listen address";
      type = str;
      default = "0.0.0.0";
      example = "127.0.0.1";
    };
    port = mkOption {
      description = "Port";
      type = port;
      default = 9100;
      example = 12345;
    };
    settings = mkOption {
      description = "Settings (env vars) for maubot-exporter";
      type = submodule {
        freeformType = attrsOf str;
        options = {
          api.base = mkOption {
            description = "The maubot base url WITHOUT the trailing slash";
            type = str;
            example = "https://maubot.example.com/_matrix/maubot/v1";
          };
          username = mkOption {
            description = "The username of a maubot user";
            type = nullOr str;
            example = "admin";
          };
          password = mkOption {
            description = "The password of the maubot user, do not use in production!";
            type = nullOr str;
            default = null;
            example = "changeme";
          };
        };
      };
      default = { };
      example = {
        api.base = "https://maubot.example.com/_matrix/maubot/v1";
        username = "admin";
        password = "changeme";
      };
    };
    environmentFile = mkOption {
      description = "path to the environment file containing variables such as the auth password";
      type = nullOr path;
      default = null;
      example = "/run/path/to/secret/environment/file.env";
    };
  };

  config = mkIf cfg.enable {
    services.maubot-exporter = {
      local = mkDefault config.services.maubot.enable;
      settings.api.base = mkDefault "http://localhost:${toString config.services.maubot.settings.server.port}/_matrix/maubot/v1";
    };

    systemd.services.maubot-exporter = {
      description = "maubot-exporter - Simple metrics exporter for maubot";
      after = optional cfg.local "maubot.service";
      requires = optional cfg.local "maubot.service";
      wantedBy = [ "multi-user.target" ];
      inherit environment;
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${getExe cfg.package} --bind ${cfg.listen}:${toString cfg.port}
        '';
        EnvironmentFile = cfg.environmentFile;
        DynamicUser = true;
        Restart = "on-failure";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = 27;
      };
    };
  };
}
