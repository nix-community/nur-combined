{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mosdns;
  settingsFormat = pkgs.formats.yaml { };

  noConfigFile = cfg.configFile == null;

  configPath =
    if noConfigFile then
      settingsFormat.generate "mosdns.yaml" cfg.settings
    else
      toString cfg.configFile;
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options = {
    services.mosdns = {
      enable = lib.mkEnableOption "mosdns DNS forwarder";

      package = lib.mkPackageOption pkgs "mosdns" { };

      configFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = "/etc/mosdns/config.yaml";
        description = ''
          Path to an existing mosdns config file.

          Setting this option overrides any configuration applied by the
          settings option.
        '';
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        example = lib.literalExpression ''
          {
            log = {
              level = "info";
              production = true;
            };

            plugins = [
              {
                tag = "forward_google";
                type = "forward";
                args = {
                  upstreams = [
                    {
                      addr = "tls://8.8.8.8";
                    }
                  ];
                };
              }
              {
                tag = "main_sequence";
                type = "sequence";
                args = [
                  {
                    exec = "$forward_google";
                  }
                ];
              }
              {
                tag = "udp_server";
                type = "udp_server";
                args = {
                  entry = "main_sequence";
                  listen = ":5335";
                };
              }
            ];
          }
        '';
        description = ''
          mosdns configuration.

          This option is ignored when configFile is set.
        '';
      };

      extraFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Extra flags passed to the mosdns command.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile != null -> cfg.settings == { };
        message = "When services.mosdns.configFile is set, settings must be empty.";
      }
    ];

    systemd.services.mosdns = {
      description = "mosdns DNS forwarder";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart =
          "${lib.getExe cfg.package} "
          + lib.escapeShellArgs (
            [
              "start"
              "-c"
              configPath
            ]
            ++ cfg.extraFlags
          );

        Type = "simple";
        Restart = "on-failure";
        RestartSec = "1s";

        RuntimeDirectory = "mosdns";
        ConfigurationDirectory = "mosdns";
        StateDirectory = "mosdns";
        CacheDirectory = "mosdns";

        # Hardening
        ReadWritePaths = [
          "/etc/mosdns"
          "/var/lib/mosdns"
          "/var/cache/mosdns"
        ];
        ReadOnlyPaths = lib.optional (!noConfigFile) cfg.configFile;

        DynamicUser = true;
        DeviceAllow = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
        RestrictNamespaces = true;

        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];
      };
    };
  };
}
