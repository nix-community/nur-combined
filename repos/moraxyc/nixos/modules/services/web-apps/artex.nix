{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.artex;
  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;
  listenAddress =
    host: port: "${if lib.hasInfix ":" host then "[${host}]" else host}:${toString port}";
in
{
  imports = [
    (lib.modules.mkRenamedOptionModule
      [ "services" "artex" "skillDir" ]
      [ "services" "artex" "settings" "ARTEX_SKILL_DIR" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "artex" "database" "url" ]
      [ "services" "artex" "settings" "ARTEX_PG_DSN" ]
    )
    (lib.modules.mkRenamedOptionModule
      [ "services" "artex" "environment" ]
      [ "services" "artex" "settings" ]
    )
  ];

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

    database.createLocally = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to configure a local PostgreSQL database and user for
        ARTEX. The database and user are both named `artex`.
      '';
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
          ARTEX_PG_DSN = lib.mkOption {
            type = lib.types.str;
            example = "postgresql://artex@db.example.org:5432/artex";
            description = ''
              PostgreSQL connection URL. Set automatically when
              {option}`services.artex.database.createLocally` is enabled.
              Passwords in this value are stored in the Nix store; use
              {option}`services.artex.environmentFile` for a secret URL instead.
            '';
          };

          ARTEX_SKILL_DIR = lib.mkOption {
            type = lib.types.path;
            default = "${cfg.package}/share/artex/skills";
            defaultText = lib.literalExpression ''"''${config.services.artex.package}/share/artex/skills"'';
            description = "Directory containing ARTEX skills, one per subdirectory.";
          };
        };
      };
      default = { };
      example = {
        ARTEX_LLM_PROVIDER = "anthropic";
        ARTEX_TRUSTED_PROXIES = "127.0.0.1";
      };
      description = "Environment variables passed to ARTEX.";
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/artex.env";
      description = ''
        Environment file read by systemd. It can contain secrets such as
        `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` and overrides values set by
        {option}`services.artex.settings`, including `ARTEX_PG_DSN`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.artex.settings = {
      ARTEX_PG_DSN = lib.mkIf cfg.database.createLocally "postgresql://artex@/artex?host=/run/postgresql";
      ARTEX_JWT_KEY_DIR = "/var/lib/artex/keys";
    };

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
      documentation = [ "https://github.com/RuoJi6/ARTEX" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
      ]
      ++ lib.optional cfg.database.createLocally "postgresql.service";
      requires = lib.optional cfg.database.createLocally "postgresql.service";

      environment = lib.mapAttrs (_: toEnvValue) cfg.settings;

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
