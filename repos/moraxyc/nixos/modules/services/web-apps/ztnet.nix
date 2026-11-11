{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ztnet;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    types
    ;

  ztFolder = "/var/lib/zerotier-one";

  formatHost = host: if lib.hasInfix ":" host then "[${host}]" else host;

  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;

  postgresqlPackage =
    if cfg.database.createLocally then config.services.postgresql.package else pkgs.postgresql;

  # ZTNET does not implement systemd socket activation. This preload adopts
  # the socket passed on fd 3 for the first listen() on $PORT, and only when
  # systemd has set LISTEN_PID to this process.
  socketActivationPreload = pkgs.writeText "ztnet-socket-activation.cjs" ''
    const net = require("node:net");

    const { LISTEN_PID, LISTEN_FDS, PORT } = process.env;
    if (LISTEN_PID === String(process.pid) && LISTEN_FDS === "1" && PORT) {
      const listen = net.Server.prototype.listen;
      net.Server.prototype.listen = function (...args) {
        const [first] = args;
        const port = first !== null && typeof first === "object" ? first.port : first;
        if (String(port) !== PORT) return listen.apply(this, args);
        net.Server.prototype.listen = listen;
        const callbacks = args.filter((arg) => typeof arg === "function");
        return listen.call(this, { fd: 3 }, ...callbacks);
      };
    }
  '';
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options.services.ztnet = {
    enable = mkEnableOption "ZTNET, a web interface for ZeroTier controllers";

    package = lib.mkPackageOption pkgs "ztnet" { };

    unixSocket = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/ztnet/ztnet.sock";
      description = ''
        Unix socket on which ZTNET listens, instead of `settings.HOSTNAME` and
        `settings.PORT`. `settings.PORT` is still passed to ZTNET, which uses it
        to identify the listening socket. systemd creates the socket with mode
        `0660`; override `systemd.sockets.ztnet.socketConfig` to change
        its owner or group.
      '';
    };

    autoMigrate = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to run ZTNET database migrations and seeding before starting the service.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/ztnet.env";
      description = ''
        Environment file containing secrets such as `NEXTAUTH_SECRET`.
        Values in it override {option}`services.ztnet.settings`.
      '';
    };

    settings = mkOption {
      type = types.submodule (
        { config, ... }:
        {
          freeformType =
            with types;
            attrsOf (
              nullOr (oneOf [
                bool
                int
                str
                path
              ])
            );

          options = {
            HOSTNAME = mkOption {
              type = types.str;
              default = "::";
              description = "Host address ZTNET listens on.";
            };

            PORT = mkOption {
              type = types.port;
              default = 3000;
              description = "Port ZTNET listens on.";
            };

            NEXTAUTH_URL = mkOption {
              type = types.str;
              example = "https://ztnet.example.com";
              description = "Public URL of the ZTNET instance.";
            };

            DATABASE_URL = mkOption {
              type = types.str;
              description = ''
                PostgreSQL connection URL. Set automatically when
                {option}`services.ztnet.database.createLocally` is enabled.
              '';
            };

            ZT_ADDR = mkOption {
              type = types.nullOr types.str;
              default = "http://127.0.0.1:9993";
              description = ''
                ZeroTier controller API address. `null` lets ZTNET use the
                address stored in its admin settings.
              '';
            };

            NEXTAUTH_URL_INTERNAL = mkOption {
              type = types.nullOr types.str;
              default =
                if cfg.unixSocket != null then
                  null
                else
                  "http://${
                    formatHost (
                      if
                        lib.elem config.HOSTNAME [
                          "::"
                          "0.0.0.0"
                        ]
                      then
                        "localhost"
                      else
                        config.HOSTNAME
                    )
                  }:${toString config.PORT}";
              defaultText = lib.literalMD "the local listening address";
              description = "URL for server-side NextAuth requests, bypassing the public URL.";
            };
          };
        }
      );
      default = { };
      example = {
        OAUTH_ALLOW_NEW_USERS = false;
      };
      description = ''
        Environment variables passed to ZTNET. `null` values are omitted.

        See <https://ztnet.network/installation/options> for available settings.
      '';
    };

    database.createLocally = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to create a local PostgreSQL database and user for ZTNET.
      '';
    };

    zerotier = {
      createLocally = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable a local ZeroTier controller via
          {option}`services.zerotierone.enable`.
        '';
      };

      secretFile = mkOption {
        type = types.nullOr types.path;
        default = "${ztFolder}/authtoken.secret";
        description = ''
          File containing the ZeroTier controller auth token. It is passed to
          ZTNET with systemd `LoadCredential`, so it may be readable by root only.
          `null` lets ZTNET use `ZT_SECRET` or the token stored in its admin settings.
        '';
      };

      manageState = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to let ZTNET modify the local ZeroTier state in
          `${ztFolder}`, required by custom planet generation, port changes,
          and ZeroTier backup and restore in the admin interface.

          This grants ZTNET `CAP_DAC_OVERRIDE`, `CAP_CHOWN` and `CAP_FOWNER`,
          write access to `/var/lib`, and permission to start and stop
          `zerotierone.service` through polkit.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null || cfg.settings ? NEXTAUTH_SECRET;
        message = ''
          services.ztnet requires NEXTAUTH_SECRET, usually via
          services.ztnet.environmentFile.
        '';
      }
      {
        assertion = cfg.zerotier.manageState -> cfg.zerotier.createLocally;
        message = ''
          services.ztnet.zerotier.manageState requires services.ztnet.zerotier.createLocally.
        '';
      }
    ];

    services.ztnet.settings = {
      DATABASE_URL = mkIf cfg.database.createLocally "postgresql://ztnet@localhost/ztnet?host=/run/postgresql";
      ZTNET_DATA_DIR = "/var/lib/ztnet";
      ZT_SECRET_FILE = mkIf (cfg.zerotier.secretFile != null) "%d/zt-authtoken";
    };

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "ztnet" ];
      ensureUsers = [
        {
          name = "ztnet";
          ensureDBOwnership = true;
        }
      ];
    };

    services.zerotierone.enable = mkIf cfg.zerotier.createLocally true;

    security.polkit = mkIf cfg.zerotier.manageState {
      enable = true;
      extraConfig = ''
        polkit.addRule(function (action, subject) {
          if (
            action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "zerotierone.service" &&
            ["start", "stop", "restart"].indexOf(action.lookup("verb")) >= 0 &&
            subject.user == "ztnet"
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    systemd.sockets.ztnet = {
      description = "ZTNET socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [
        (
          if cfg.unixSocket != null then
            cfg.unixSocket
          else
            "${formatHost cfg.settings.HOSTNAME}:${toString cfg.settings.PORT}"
        )
      ];
      socketConfig =
        if cfg.unixSocket != null then
          {
            SocketMode = lib.mkDefault "0660";
          }
        else
          {
            # Socket units start before network-online.target, so the address may not exist yet.
            FreeBind = true;
          };
    };

    systemd.services.ztnet = {
      description = "ZTNET";
      documentation = [ "https://ztnet.network/" ];

      after = [
        "ztnet.socket"
        "network-online.target"
      ]
      ++ optional cfg.database.createLocally "postgresql.service"
      ++ optional cfg.zerotier.createLocally "zerotierone.service";

      # Not requires: restoring a ZeroTier backup stops zerotierone.service.
      wants = [
        "network-online.target"
      ]
      ++ optional cfg.zerotier.createLocally "zerotierone.service";

      requires = [
        "ztnet.socket"
      ]
      ++ optional cfg.database.createLocally "postgresql.service";

      # Backup and restore in the admin interface.
      path = [
        postgresqlPackage
        pkgs.gnutar
        pkgs.gzip
        pkgs.bzip2
        pkgs.xz
      ];

      environment = {
        NODE_OPTIONS = "--require ${socketActivationPreload}";
      }
      // lib.mapAttrs (_: toEnvValue) (lib.filterAttrs (_: v: v != null) cfg.settings);

      serviceConfig =
        lib.optionalAttrs cfg.autoMigrate {
          ExecStartPre = [
            (lib.getExe' cfg.package "ztnet-migrate")
            (lib.getExe' cfg.package "ztnet-seed")
          ];
        }
        // {
          ExecStart = lib.getExe cfg.package;
          Type = "simple";

          Restart = "on-failure";
          RestartSec = "5s";

          DynamicUser = true;
          User = "ztnet";
          Group = "ztnet";

          EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
          LoadCredential = optional (
            cfg.zerotier.secretFile != null
          ) "zt-authtoken:${cfg.zerotier.secretFile}";

          StateDirectory = "ztnet";
          CacheDirectory = "ztnet";
          RuntimeDirectory = "ztnet";

          # Renaming the ZeroTier folder during restore needs its parent.
          ReadWritePaths = optional cfg.zerotier.manageState "/var/lib";
          AmbientCapabilities = lib.optionals cfg.zerotier.manageState [
            "CAP_CHOWN"
            "CAP_DAC_OVERRIDE"
            "CAP_FOWNER"
          ];
          CapabilityBoundingSet =
            if cfg.zerotier.manageState then
              [
                "CAP_CHOWN"
                "CAP_DAC_OVERRIDE"
                "CAP_FOWNER"
              ]
            else
              "";

          # Hardening
          LockPersonality = true;
          MemoryDenyWriteExecute = false; # Required by V8 JIT
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          # Capabilities do not apply to host files in a user namespace.
          PrivateUsers = !cfg.zerotier.manageState;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ]
          ++ optional cfg.zerotier.manageState "@chown";
        };
    };
  };
}
