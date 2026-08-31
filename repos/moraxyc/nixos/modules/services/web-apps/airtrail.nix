{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.airtrail;
  defaultDatabaseUrl = "postgresql://airtrail@localhost/airtrail?host=/run/postgresql";
in
{
  options.services.airtrail = {
    enable = lib.mkEnableOption "AirTrail, a self-hosted personal flight tracker";

    package = lib.mkPackageOption pkgs "airtrail" { };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "Address on which the AirTrail web server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "TCP port on which the AirTrail web server listens.";
    };

    origin = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:3000";
      example = "https://airtrail.example.org";
      description = ''
        The public URL used to access AirTrail. This value is used for
        authentication cookies and must match the URL used by clients.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the AirTrail port in the firewall.";
    };

    configureNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to configure nginx as a reverse proxy for AirTrail.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "airtrail.example.org";
      description = "Domain name for the nginx virtual host.";
    };

    behindProxy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether AirTrail is running behind a reverse proxy that supplies
        `X-Forwarded-Proto` and `X-Forwarded-Host` headers.
      '';
    };

    bodySizeLimit = lib.mkOption {
      type = lib.types.str;
      default = "20M";
      description = "Maximum HTTP request body size accepted by AirTrail.";
    };

    database = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to configure a local PostgreSQL database and user for
          AirTrail. The database and user are both named `airtrail`.
        '';
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = defaultDatabaseUrl;
        defaultText = lib.literalExpression ''"postgresql://airtrail@localhost/airtrail?host=/run/postgresql"'';
        example = "postgresql://airtrail:password@db.example.org:5432/airtrail";
        description = ''
          PostgreSQL connection URL. Passwords in this value are stored in the
          Nix store; use {option}`services.airtrail.environmentFile` with a
          `DB_URL` entry for a secret URL instead. Values from the environment
          file override this value.
        '';
      };
    };

    automaticMigrations = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to run AirTrail database migrations before starting the service.";
    };

    environment = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          int
          str
          path
          package
        ]);
      default = { };
      example = {
        OAUTH_ENABLED = true;
        OAUTH_ISSUER_URL = "https://auth.example.org";
      };
      description = ''
        Additional environment variables passed to AirTrail. Values managed by
        module options take precedence; use {option}`environmentFile` for
        secrets or to override them.

        See <https://airtrail.johanohly.com/docs/features/oauth> for supported
        configuration variables.
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/airtrail.env";
      description = ''
        Environment file read by systemd. It can contain secrets and overrides
        values set by {option}`services.airtrail.environment`, including
        `DB_URL`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.url == defaultDatabaseUrl;
        message = ''
          services.airtrail.database.url must not be changed while
          services.airtrail.database.createLocally is enabled.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "airtrail" ];
      ensureUsers = [
        {
          name = "airtrail";
          ensureDBOwnership = true;
        }
      ];
    };

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    systemd.services.airtrail = {
      description = "AirTrail personal flight tracker";
      documentation = [ "https://github.com/johanohly/AirTrail" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ] ++ lib.optional cfg.database.createLocally "postgresql.service";
      requires = lib.optional cfg.database.createLocally "postgresql.service";

      environment =
        cfg.environment
        // {
          NODE_ENV = "production";
          HOST = cfg.host;
          PORT = toString cfg.port;
          ORIGIN = cfg.origin;
          DB_URL = defaultDatabaseUrl;
          BODY_SIZE_LIMIT = cfg.bodySizeLimit;
          UPLOAD_LOCATION = "/var/lib/airtrail/uploads";
        }
        // lib.optionalAttrs (cfg.behindProxy || cfg.configureNginx) {
          PROTOCOL_HEADER = "x-forwarded-proto";
          HOST_HEADER = "x-forwarded-host";
        }
        // {
          DB_URL = cfg.database.url;
        };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe cfg.package;
        ExecStartPre = lib.optional cfg.automaticMigrations (lib.getExe' cfg.package "airtrail-migrate");
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

        User = "airtrail";
        Group = "airtrail";
        DynamicUser = true;

        WorkingDirectory = "${cfg.package}/share/airtrail";
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "airtrail";
        StateDirectoryMode = "0750";

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # Required by V8 JIT
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
