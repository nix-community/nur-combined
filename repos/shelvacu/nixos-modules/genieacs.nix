{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types flip;
  cfg = config.services.genieacs;
  enableAny = cfg.cwmp.enable || cfg.nbi.enable || cfg.fs.enable || cfg.ui.enable;
  extensionsPkg = pkgs.linkFarmFromDrvs "genieacs-extensions" cfg.extensions;
  envVarsType = types.attrsOf (types.nullOr (types.either types.str types.int));
  commonOptsModule =
    { serviceShortName, config, ... }:
    let
      environmentVarsUnprefixed = {
        WORKER_PROCESSES = config.workerProcesses;
        PORT = config.port;
        INTERFACE = config.interface;
        SSL_CERT = config.sslCert;
        SSL_KEY = config.sslKey;
        ACCESS_LOG_FILE = config.accessLogFile;
        LOG_FILE = config.eventLogFile;
      };
      serviceNameCaps = lib.toUpper serviceShortName;
      environmentVars = lib.concatMapAttrs (key: val: {
        "GENIEACS_${serviceNameCaps}_${key}" = val;
      }) environmentVarsUnprefixed;
    in
    {
      options = {
        enable = mkOption {
          type = types.bool;
          description = "Enable GenieACS ${serviceShortName} service";
          default = false;
        };
        accessLogFile = mkOption {
          type = types.nullOr types.path;
          default = "/var/log/genieacs/genieacs-${serviceShortName}-access.log";
          description = "File to log incoming requests for genieacs-${serviceShortName}. If `null`, logs will go to stdout. This sets `GENIEACS_${serviceNameCaps}_ACCESS_LOG_FILE`";
        };
        workerProcesses = mkOption {
          type = types.int;
          default = 0;
          description = "The number of worker processes to spawn for genieacs-${serviceShortName}. A value of 0 means as many as there are CPU cores available. This sets `GENIEACS_${serviceNameCaps}_WORKER_PROCESSES`";
        };
        port = mkOption {
          type = types.port;
          description = "The TCP port that genieacs-${serviceShortName} listens on. This sets `GENIEACS_${serviceNameCaps}_PORT`";
        };
        interface = mkOption {
          type = types.str;
          default = "::";
          description = "The network interface (ip address, really) that genieacs-${serviceShortName} binds to. This sets `GENIEACS_${serviceNameCaps}_INTERFACE`";
        };
        sslCert = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to certificate file. If `null`, non-secure HTTP will be used. This sets `GENIEACS_${serviceNameCaps}_SSL_CERT`";
        };
        sslKey = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to certificate key file. If `null`, non-secure HTTP will be used. This sets `GENIEACS_${serviceNameCaps}_SSL_KEY`";
        };
        eventLogFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "File to log process related events for genieacs-${serviceShortName}. If `null`, logs will go to stderr. This sets `GENIEACS_${serviceNameCaps}_LOG_FILE`";
        };
        extraEnv = mkOption {
          type = envVarsType;
          default = { };
          example = ''{ NODE_OPTIONS = "--enable-source-maps"; }'';
        };

        asEnvironmentVars = mkOption {
          type = envVarsType;
          internal = true;
          readOnly = true;
          default = environmentVars // config.extraEnv;
          defaultText = "internal";
        };
      };
    };
  envAllNoPrefix = {
    MONGODB_CONNECTION_URL = cfg.mongodbConnectionUrl;
    EXT_DIR = "${extensionsPkg}";
    EXT_TIMEOUT = cfg.extensionTimeout;
    DEBUG_FILE = cfg.debugFile;
    DEBUG_FORMAT = cfg.debugFormat;
    LOG_FORMAT = cfg.eventLogFormat;
    ACCESS_LOG_FORMAT = cfg.accessLogFormat;
  };
  envAll = lib.pipe envAllNoPrefix [
    (lib.filterAttrs (_: val: val != null))
    (lib.concatMapAttrs (key: val: { "GENIEACS_${key}" = val; }))
  ];
  envEach = {
    cwmp = envAll // cfg.cwmp.asEnvironmentVars;
    nbi = envAll // cfg.nbi.asEnvironmentVars;
    fs = envAll // cfg.fs.asEnvironmentVars // { GENIEACS_FS_URL_PREFIX = cfg.urlPrefix; };
    ui = envAll // cfg.ui.asEnvironmentVars;
  };
  serviceNames = [
    "cwmp"
    "nbi"
    "fs"
    "ui"
  ];
  services = map (name: {
    inherit name;
    config = cfg.${name};
    env = envEach.${name};
  }) serviceNames;
  mkServiceOption =
    serviceShortName:
    mkOption {
      type = types.submoduleWith {
        modules = [ commonOptsModule ];
        specialArgs = { inherit serviceShortName; };
      };
      default = { };
    };
in
{
  options.services.genieacs = {
    defaults = mkOption {
      type = types.deferredModule;
      default = { };
    };
    user = mkOption {
      type = types.str;
      default = "genieacs";
      description = "The user name under which to run GenieACS services";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      defaultText = ''{option}`user`'';
      description = "The group under which to run GenieACS services";
    };
    package = lib.mkPackageOption pkgs "genieacs" { };
    extensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
    mongodbConnectionUrl = mkOption {
      type = types.str;
      example = "mongodb://127.0.0.1/genieacs";
      description = "The connection URL for the mongodb server. This sets `GENIEACS_MONGODB_CONNECTION_URL`";
    };
    extensionTimeout = mkOption {
      type = types.int;
      default = 3000;
      description = "Timeout (in milliseconds) to allow for calls to extensions to return a response. This sets `GENIEACS_EXT_TIMEOUT`";
    };
    debugFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File to dump CPE debug log. No debug log is dumped if set to `null`. This sets `GENIEACS_DEBUG_FILE`";
    };
    debugFormat = mkOption {
      type = types.enum [
        "yaml"
        "json"
      ];
      default = "yaml";
      description = "Debug log format. This sets `GENIEACS_DEBUG_FORMAT`";
    };
    eventLogFormat = mkOption {
      type = types.enum [
        "simple"
        "json"
      ];
      default = "simple";
      description = "The format used for the log entries in {option}`eventLogFile`. This sets `GENIEACS_LOG_FORMAT`";
    };
    accessLogFormat = mkOption {
      type = types.enum [
        "simple"
        "json"
      ];
      default = "simple";
      description = "The format used for the log entries in {option}`accessLogFile`. This sets `GENIEACS_ACCESS_LOG_FORMAT`";
    };
    urlPrefix = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://my-genieacs-install.example.com:4567/";
      description = ''
        The URL prefix to use when generating the file URL for TR-069 Download requests. Set this if genieacs-fs and genieacs-cwmp are behind a proxy or running on different servers.

        If `null` (default): auto generated based on the hostname from the ACS URL, FS_PORT config, and whether or not SSL is enabled for genieacs-fs.

        This sets `GENIEACS_FS_URL_PREFIX`
      '';
    };
    jwtSecret.path = mkOption {
      type = types.path;
      default = "/var/lib/genieacs/jwt-secret.key";
    };
    jwtSecret.autoGenerate = mkOption {
      type = types.bool;
      default = true;
    };

    cwmp = mkServiceOption "cwmp";
    nbi = mkServiceOption "nbi";
    fs = mkServiceOption "fs";
    ui = mkServiceOption "ui";
  };

  config = lib.mkMerge (
    [
      {
        assertions = [
          {
            assertion =
              let
                allPorts = builtins.concatMap ({ config, ... }: lib.optional config.enable config.port) services;
              in
              lib.allUnique allPorts;
            message =
              "services.genieacs: All enabled genieacs services must listen on unique ports. Current ports assignments: "
              + (lib.concatMapStringsSep " " (
                { name, config, ... }: lib.optionalString config.enable "${name}=${config.port}"
              ) services);
          }
        ]
        ++ flip lib.map services (
          { name, config, ... }:
          {
            assertion = (config.sslCert == null) == (config.sslKey == null);
            message = "services.genieacs.${name}: sslCert and sslKey must either both be null or both be non-null";
          }
        );
        services.genieacs.cwmp = cfg.defaults;
        services.genieacs.nbi = cfg.defaults;
        services.genieacs.fs = cfg.defaults;
        services.genieacs.ui = cfg.defaults;
      }
      (lib.mkIf enableAny {
        users.users.${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
        };
        users.groups.${cfg.group} = { };

        systemd.targets.genieacs = {
          description = "Target for all GenieACS services";
          wantedBy = [ "multi-user.target" ];
        };
      })
      (lib.mkIf cfg.ui.enable {
        systemd.services.genieacs-ui = {
          script = ''
            set -euo pipefail
            jwt_path=${lib.escapeShellArg cfg.jwtSecret.path}
            ${lib.optionalString cfg.jwtSecret.autoGenerate ''
              if ! [[ -f "$jwt_path" ]]; then
                umask 077
                od -vN "128" -An -tx1 /dev/urandom | tr -d " \n" > "$jwt_path"
              fi
            ''}
            GENIEACS_UI_JWT_SECRET="$(cat "$jwt_path")"
            export GENIEACS_UI_JWT_SECRET
            ${cfg.package}/bin/genieacs-ui
          '';
          serviceConfig.BindPaths = [ (builtins.dirOf cfg.jwtSecret.path) ];
        };
      })
    ]
    ++ flip map services (
      {
        name,
        config,
        env,
      }:
      lib.mkIf config.enable {
        # for those of you ripgrepping, this is what makes genieacs-cwmp.service, genieacs-nbi.service, genieacs-fs.service, and genieacs-ui.service
        systemd.services."genieacs-${name}" = {
          description = "GenieACS ${name} service";
          wantedBy = [ "genieacs.target" ];
          after = [ "network.target" ];
          environment = builtins.mapAttrs (_: v: if builtins.isInt v then toString v else v) env;
          serviceConfig = {
            Type = "exec";
            User = cfg.user;
            Group = cfg.group;
            #mkDefault so genieacs-ui.script can override it
            ExecStart = lib.mkDefault "${cfg.package}/bin/genieacs-${name}";

            BindReadOnlyPaths = [
              "/nix/store"
              "-/etc/resolv.conf"
              "-/etc/nsswitch.conf"
              "-/etc/hosts"
              "-/etc/localtime"
            ];
            BindPaths =
              [ ]
              ++ lib.optional (config.accessLogFile != null) (builtins.dirOf config.accessLogFile)
              ++ lib.optional (config.eventLogFile != null) (builtins.dirOf config.eventLogFile);
            CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
            AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];

            DeviceAllow = "";
            ProtectSystem = "strict";
            LockPersonality = true;
            # it's nodejs, which has a JIT, so it needs write-execute memory
            # MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateMounts = true;
            PrivateTmp = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectControlGroups = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
            ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [
              "@system-service"
              "~pkey_alloc:ENOSPC"
            ];
          };
        };
      }
    )
  );
}
