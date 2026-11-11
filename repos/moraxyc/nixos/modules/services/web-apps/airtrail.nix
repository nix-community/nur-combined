{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.airtrail;
  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;
  listenStream =
    host: port: "${if lib.hasInfix ":" host then "[${host}]" else host}:${toString port}";
in
{
  imports = [
    (lib.modules.mkRenamedOptionModule
      [ "services" "airtrail" "host" ]
      [ "services" "airtrail" "settings" "HOST" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "airtrail" "port" ]
      [ "services" "airtrail" "settings" "PORT" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "airtrail" "origin" ]
      [ "services" "airtrail" "settings" "ORIGIN" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "airtrail" "bodySizeLimit" ]
      [ "services" "airtrail" "settings" "BODY_SIZE_LIMIT" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "airtrail" "database" "url" ]
      [ "services" "airtrail" "settings" "DB_URL" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "airtrail" "environment" ]
      [ "services" "airtrail" "settings" ]
    )
    (lib.modules.mkRemovedOptionModule [
      "services"
      "airtrail"
      "behindProxy"
    ] "Set `PROTOCOL_HEADER` and `HOST_HEADER` in services.airtrail.settings instead.")
  ];

  options.services.airtrail = {
    enable = lib.mkEnableOption "AirTrail, a self-hosted personal flight tracker";

    package = lib.mkPackageOption pkgs "airtrail" { };

    unixSocket = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/airtrail/airtrail.sock";
      description = ''
        Unix socket on which the AirTrail web server listens, instead of
        `settings.HOST` and `settings.PORT`. systemd creates the socket with
        mode `0660`; when {option}`services.airtrail.configureNginx` is enabled
        its group is set to nginx's group. Override
        `systemd.sockets.airtrail.socketConfig` to change the permissions.
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

    database.createLocally = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to configure a local PostgreSQL database and user for
        AirTrail. The database and user are both named `airtrail`.
      '';
    };

    automaticMigrations = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to run AirTrail database migrations before starting the service.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
            path
            package
          ]);

        options = {
          HOST = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            example = "0.0.0.0";
            description = "Address on which the AirTrail web server listens.";
          };

          PORT = lib.mkOption {
            type = lib.types.port;
            default = 3000;
            description = "TCP port on which the AirTrail web server listens.";
          };

          ORIGIN = lib.mkOption {
            type = lib.types.str;
            default = "https://${cfg.domain}";
            defaultText = lib.literalExpression ''"https://''${config.services.airtrail.domain}"'';
            example = "https://airtrail.example.org";
            description = ''
              The public URL used to access AirTrail. This value is used for
              authentication cookies and must match the URL used by clients.
            '';
          };

          DB_URL = lib.mkOption {
            type = lib.types.str;
            example = "postgresql://airtrail@db.example.org:5432/airtrail";
            description = ''
              PostgreSQL connection URL. Set automatically when
              {option}`services.airtrail.database.createLocally` is enabled.
              Passwords in this value are stored in the Nix store; use
              {option}`services.airtrail.environmentFile` for a secret URL instead.
            '';
          };

          BODY_SIZE_LIMIT = lib.mkOption {
            type = lib.types.str;
            default = "20M";
            description = "Maximum HTTP request body size accepted by AirTrail.";
          };
        };
      };
      default = { };
      example = {
        OAUTH_ENABLED = true;
        OAUTH_ISSUER_URL = "https://auth.example.org";
        PROTOCOL_HEADER = "x-forwarded-proto";
        HOST_HEADER = "x-forwarded-host";
      };
      description = ''
        Environment variables passed to AirTrail.

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
        values set by {option}`services.airtrail.settings`, including
        `DB_URL`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.unixSocket != null -> !cfg.openFirewall;
        message = ''
          services.airtrail.openFirewall cannot be used together with
          services.airtrail.unixSocket.
        '';
      }
    ];

    services.airtrail.settings = {
      NODE_ENV = "production";
      UPLOAD_LOCATION = "/var/lib/airtrail/uploads";
      DB_URL = lib.mkIf cfg.database.createLocally "postgresql://airtrail@localhost/airtrail?host=/run/postgresql";
      PROTOCOL_HEADER = lib.mkIf cfg.configureNginx (lib.mkDefault "x-forwarded-proto");
      HOST_HEADER = lib.mkIf cfg.configureNginx (lib.mkDefault "x-forwarded-host");
    };

    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.settings.PORT;

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
          proxyPass =
            if cfg.unixSocket != null then
              "http://unix:${cfg.unixSocket}:/"
            else
              "http://127.0.0.1:${toString cfg.settings.PORT}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    systemd.sockets.airtrail = {
      description = "AirTrail socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [
        (
          if cfg.unixSocket != null then cfg.unixSocket else listenStream cfg.settings.HOST cfg.settings.PORT
        )
      ];
      socketConfig =
        if cfg.unixSocket != null then
          {
            SocketMode = lib.mkDefault "0660";
            SocketGroup = lib.mkIf cfg.configureNginx (lib.mkDefault config.services.nginx.group);
          }
        else
          {
            # Socket units start before network-online.target, so the address may not exist yet.
            FreeBind = true;
          };
    };

    systemd.services.airtrail = {
      description = "AirTrail personal flight tracker";
      documentation = [ "https://github.com/johanohly/AirTrail" ];
      wants = [ "network-online.target" ];
      after = [
        "airtrail.socket"
        "network-online.target"
      ]
      ++ lib.optional cfg.database.createLocally "postgresql.service";
      requires = [ "airtrail.socket" ] ++ lib.optional cfg.database.createLocally "postgresql.service";

      environment = lib.mapAttrs (_: toEnvValue) cfg.settings;

      preStart = ''
        mkdir -p /var/lib/airtrail/uploads
      '';

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
