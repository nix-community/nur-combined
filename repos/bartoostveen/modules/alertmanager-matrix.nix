{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    mkIf
    getExe
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
    attrs
    submodule
    nullOr
    str
    bool
    enum
    path
    ;

  cfg = config.services.alertmanager-matrix;

  environment = pipe cfg.settings [
    (mapAttrsRecursive (
      path: value:
      optionalAttrs (value != null) {
        name = toUpper (concatStringsSep "_" path);
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
  options.services.alertmanager-matrix = {
    enable = mkEnableOption "alertmanager-matrix: Service for managing and receiving Alertmanager alerts on Matrix";
    package = mkPackageOption pkgs "alertmanager-matrix" { };
    useLocalAlertmanager = mkEnableOption "usage of the local alertmanager instance";
    environmentFile = mkOption {
      description = "Path to the alertmanager-matrix environment file";
      type = nullOr path;
      default = null;
      example = "/path/to/alertmanager-matrix/.env";
    };
    settings = mkOption {
      description = ''
        Settings for alertmanager-matrix. Option descriptions are copied from upstream.

        ::: {.warning}
        These settings will be world-readable, do not use for secrets!
        Instead, specify a secret environment file in {option}`services.alertmanager-matrix.environmentFile`.
        These settings get merged with {option}`services.alertmanager-matrix.settings`, with the environment file having precedence.
        :::
      '';
      type = submodule {
        freeformType = attrs;
        options = {
          addr = mkOption {
            description = ''
              Address to listen on.
            '';
            type = str;
            default = ":4051";
          };
          homeserver = mkOption {
            description = ''
              Homeserver to connect to.
            '';
            type = str;
            default = "http://localhost:8008";
          };
          user.id = mkOption {
            description = ''
              User ID to connect with.
            '';
            type = nullOr str;
            default = null;
          };
          token = mkOption {
            description = ''
              Token to connect with.

              ::: {.warning}
              This token will be world-readable! Never use this in production!
              Instead, specify a secret environment file in {option}`services.alertmanager-matrix.environmentFile`.
              These settings get merged with {option}`services.alertmanager-matrix.settings`, with the environment file having precedence.
              :::
            '';
            type = nullOr str;
            default = null;
          };
          rooms = mkOption {
            description = ''
              Comma separated list of allowed rooms. All rooms are allowed by default.
            '';
            type = nullOr str;
            default = null;
          };
          alertmanager = mkOption {
            description = ''
              Alertmanager to connect to.
            '';
            type = str;
            default = "http://localhost:9093";
          };
          message.type = mkOption {
            description = ''
              Type of message the bot uses.
            '';
            type = enum [
              "m.text"
              "m.notice"
            ];
            default = "m.notice";
          };
          icon.file = mkOption {
            description = ''
              YAML file with icons for message types.
            '';
            type = nullOr str;
            default = null;
          };
          color.file = mkOption {
            description = ''
              YAML file with colors for message types.
            '';
            type = nullOr str;
            default = null;
          };
          html.template = mkOption {
            description = ''
              HTML template for alert messages.
            '';
            type = nullOr str;
            default = null;
          };
          text.template = mkOption {
            description = ''
              Plain-text template for alert messages.
            '';
            type = nullOr str;
            default = null;
          };
          log.level = mkOption {
            description = ''
              Log level
            '';
            type = str;
            default = "info";
          };
          show.labels = mkOption {
            description = ''
              show labels of alerts messages.
            '';
            type = bool;
            default = false;
          };
        };
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.useLocalAlertmanager -> config.services.prometheus.alertmanager.enable;
        message = "When setting useLocalAlertmanager, a Prometheus alertmanager should run locally, but services.prometheus.alertmanager.enable is currently false!";
      }
    ];

    services.alertmanager-matrix.settings.alertmanager = mkIf cfg.useLocalAlertmanager (
      let
        alertmanager = config.services.prometheus.alertmanager;
      in
      "http://${alertmanager.listenAddress}:${toString alertmanager.port}"
    );

    systemd.services.alertmanager-matrix = {
      description = "alertmanager-matrix: Service for managing and receiving Alertmanager alerts on Matrix";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      inherit environment;
      serviceConfig = {
        Type = "simple";
        ExecStart = getExe cfg.package;
        EnvironmentFile = cfg.environmentFile;
        Restart = "on-failure";
        DynamicUser = true;
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
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
