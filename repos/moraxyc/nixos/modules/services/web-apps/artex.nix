{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.artex;
  defaultDatabaseUrl = "postgresql://artex@/artex?host=/run/postgresql";
  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;
  listenAddress =
    host: port: "${if lib.hasInfix ":" host then "[${host}]" else host}:${toString port}";
in
{
  options.services.artex = {
    enable = lib.mkEnableOption "ARTEX, an AI autonomous penetration testing system";

    package = lib.mkPackageOption pkgs "artex" { };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "Address on which the ARTEX web server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "TCP port on which the ARTEX web server listens.";
    };

    proxy = {
      enable = lib.mkEnableOption "the ARTEX traffic recording proxy" // {
        default = true;
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address on which the traffic recording proxy listens.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8788;
        description = "TCP port on which the traffic recording proxy listens.";
      };
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the ARTEX web server port in the firewall.";
    };

    configureNginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to configure nginx as a reverse proxy for ARTEX.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "artex.example.org";
      description = "Domain name for the nginx virtual host.";
    };

    skillDir = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.package}/share/artex/skills";
      defaultText = lib.literalExpression ''"''${config.services.artex.package}/share/artex/skills"'';
      description = "Directory containing ARTEX skills, one per subdirectory.";
    };

    database = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to configure a local PostgreSQL database and user for
          ARTEX. The database and user are both named `artex`.
        '';
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = defaultDatabaseUrl;
        defaultText = lib.literalExpression ''"postgresql://artex@/artex?host=/run/postgresql"'';
        example = "postgresql://artex:password@db.example.org:5432/artex";
        description = ''
          PostgreSQL connection URL. Passwords in this value are stored in the
          Nix store; use {option}`services.artex.environmentFile` with an
          `ARTEX_PG_DSN` entry for a secret URL instead. Values from the
          environment file override this value.
        '';
      };
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
        ARTEX_LLM_PROVIDER = "anthropic";
        ARTEX_TRUSTED_PROXIES = "127.0.0.1";
      };
      description = ''
        Additional environment variables passed to ARTEX. Values managed by
        module options take precedence; use {option}`environmentFile` for
        secrets or to override them.
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/artex.env";
      description = ''
        Environment file read by systemd. It can contain secrets such as
        `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` and overrides values set by
        {option}`services.artex.environment`, including `ARTEX_PG_DSN`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.url == defaultDatabaseUrl;
        message = ''
          services.artex.database.url must not be changed while
          services.artex.database.createLocally is enabled.
        '';
      }
    ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "artex" ];
      ensureUsers = [
        {
          name = "artex";
          ensureDBOwnership = true;
        }
      ];
    };

    services.nginx = lib.mkIf cfg.configureNginx {
      enable = lib.mkDefault true;
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://${listenAddress cfg.host cfg.port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    systemd.services.artex = {
      description = "ARTEX AI autonomous penetration testing system";
      documentation = [ "https://github.com/BaaRai/ARTEX" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
      ]
      ++ lib.optional cfg.database.createLocally "postgresql.service";
      requires = lib.optional cfg.database.createLocally "postgresql.service";

      environment = (lib.mapAttrs (_: toEnvValue) cfg.environment) // {
        ARTEX_PG_DSN = cfg.database.url;
        ARTEX_SKILL_DIR = toString cfg.skillDir;
        ARTEX_JWT_KEY_DIR = "/var/lib/artex/keys";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.escapeShellArgs ([
          (lib.getExe cfg.package)
          "-addr"
          (listenAddress cfg.host cfg.port)
          "-data"
          "/var/lib/artex/data"
          "-proxy"
          (lib.optionalString cfg.proxy.enable (listenAddress cfg.proxy.host cfg.proxy.port))
        ]);
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

        DynamicUser = true;
        User = "artex";
        Group = "artex";

        WorkingDirectory = "/var/lib/artex";
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = "artex";
        StateDirectoryMode = "0750";

        # Hardening
        CapabilityBoundingSet = "";
        LockPersonality = true;
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
