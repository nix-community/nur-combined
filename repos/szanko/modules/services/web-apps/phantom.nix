{ lib, pkgs, config, ... }:

let
  cfg = config.services.phantom;
in
{
  options.services.phantom = {
    enable = lib.mkEnableOption "Phantom (alternative frontend for fandom.com)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.phantom;
      defaultText = lib.literalExpression "pkgs.phantom";
      description = "The Phantom package to run.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "phantom";
      description = "User account under which Phantom runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "phantom";
      description = "Group under which Phantom runs.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/phantom";
      description = "Writable state directory for Phantom.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      example = "127.0.0.1";
      description = "Bind address (SERVER_HOST).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      example = 80;
      description = "Listen port (SERVER_PORT).";
    };

    instanceName = lib.mkOption {
      type = lib.types.str;
      default = "kuuro.net";
      example = "nadeko.net";
      description = "Instance name (INSTANCE_NAME).";
    };

    theme = lib.mkOption {
      type = lib.types.enum [ "dark" "light" ];
      default = "dark";
      description = "Instance theme (INSTANCE_THEME).";
    };

    jsEnabled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether instance JavaScript is enabled (INSTANCE_JS_ENABLED).";
    };

    cache = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable cache (CACHE_ENABLED).";
      };

      duration = lib.mkOption {
        type = lib.types.int;
        default = 86400;
        example = 3600;
        description = "Cache duration in seconds (CACHE_DURATION).";
      };
    };

    # Logging
    logLevel = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "Log level (LOG_LEVEL).";
    };

    # Extras
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open firewall for the configured port.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command-line arguments passed to phantom.";
    };

    extraEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables (merged on top of generated ones).";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == "phantom") {
      phantom = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "phantom") {
      phantom = { };
    };

    systemd.services.phantom = {
      description = "Phantom web service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment =
        {
          SERVER_HOST = cfg.host;
          SERVER_PORT = toString cfg.port;

          INSTANCE_NAME = cfg.instanceName;
          INSTANCE_THEME = cfg.theme;
          INSTANCE_JS_ENABLED = lib.boolToString cfg.jsEnabled;

          CACHE_ENABLED = lib.boolToString cfg.cache.enable;
          CACHE_DURATION = toString cfg.cache.duration;

          LOG_LEVEL = cfg.logLevel;
        }
        // cfg.extraEnvironment;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        WorkingDirectory = cfg.dataDir;
        StateDirectory = "phantom";

        ExecStart = lib.escapeShellArgs (
          [ "${cfg.package}/bin/phantom" ] ++ cfg.extraArgs
        );

        Restart = "on-failure";
        RestartSec = 2;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;

        ReadWritePaths = [ cfg.dataDir ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}

