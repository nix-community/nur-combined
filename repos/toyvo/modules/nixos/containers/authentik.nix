{
  config,
  lib,
  pkgs,
  homelab,
  ...
}:
let
  cfg = config.nixcfg.containers.authentik;
  ids = config.ids;
in
{
  options.nixcfg.containers.authentik = {
    enable = lib.mkEnableOption "Authentik SSO container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.15";
      description = "Host side of the veth pair for the authentik server container";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.16";
      description = "Authentik server container IP address";
    };

    workerHostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.17";
      description = "Host side of the veth pair for the authentik worker container";
    };

    workerLocalAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.18";
      description = "Authentik worker container IP address";
    };

    redisHostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.19";
      description = "Host side of the veth pair for the authentik redis container";
    };

    redisLocalAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.20";
      description = "Authentik redis container IP address";
    };

    natInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host WAN-facing interface for NAT masquerade";
    };

    db.location = lib.mkOption {
      type = lib.types.enum [
        "internal"
        "external"
      ];
      default = "external";
      description = "Where PostgreSQL runs. 'external' uses host PostgreSQL, 'internal' provisions a dedicated container.";
    };

    db.host = lib.mkOption {
      type = lib.types.str;
      default = config.nixcfg.containers.authentik.hostAddress;
      description = "PostgreSQL host address (reachable from container)";
    };

    db.port = lib.mkOption {
      type = lib.types.port;
      default = 5432;
      description = "PostgreSQL port";
    };

    db.name = lib.mkOption {
      type = lib.types.str;
      default = "authentik";
      description = "PostgreSQL database name";
    };

    db.user = lib.mkOption {
      type = lib.types.str;
      default = "authentik";
      description = "PostgreSQL user name";
    };

    db.passwordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the PostgreSQL password file on the host (decrypted by sops; bind-mounted read-only into containers)";
    };

    redis.location = lib.mkOption {
      type = lib.types.enum [
        "internal"
        "external"
      ];
      default = "internal";
      description = "Where Redis runs. 'internal' provisions a dedicated container, 'external' uses a host-level Redis.";
    };

    redis.host = lib.mkOption {
      type = lib.types.str;
      default = config.nixcfg.containers.authentik.redisLocalAddress;
      description = "Redis host address (reachable from container)";
    };

    redis.port = lib.mkOption {
      type = lib.types.port;
      default = 6379;
      description = "Redis port";
    };

    secretKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Authentik secret key file on the host (decrypted by sops; bind-mounted read-only into containers)";
    };

    bootstrapPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Authentik bootstrap admin password file on the host (decrypted by sops; bind-mounted read-only into server container)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = homelab.authentik.services.authentik.port;
      description = "Authentik server listen port";
    };

    ldap.port = lib.mkOption {
      type = lib.types.port;
      default = 6636;
      description = "LDAP outpost listen port (LDAPS)";
    };

    ldap.tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the LDAP outpost token file on the host (decrypted by sops; bind-mounted read-only into container)";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = lib.mkIf (cfg.natInterface != null) {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [
        "ve-authentik"
        "ve-ak-worker"
        "ve-ak-redis"
      ];
    };

    services.postgresql = lib.mkIf (cfg.db.location == "external") {
      ensureDatabases = [ cfg.db.name ];
      ensureUsers = [
        {
          name = cfg.db.user;
          ensureDBOwnership = true;
        }
      ];
    };

    sops.secrets."authentik-secret-key".mode = "0444";
    sops.secrets."authentik-bootstrap-password".mode = "0444";
    sops.secrets."authentik-db-password".mode = "0444";
    sops.secrets."authentik-ldap-token".mode = "0444";

    systemd.tmpfiles.rules = [
      "d /var/lib/nixos-containers/authentik/var/log/journal 0755 root systemd-journal -"
      "d /var/lib/nixos-containers/ak-worker/var/log/journal 0755 root systemd-journal -"
      "d /var/lib/nixos-containers/ak-redis/var/log/journal 0755 root systemd-journal -"
    ];

    containers.authentik = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        "/run/secrets/authentik-secret-key" = {
          hostPath = cfg.secretKeyFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-bootstrap-password" = {
          hostPath = cfg.bootstrapPasswordFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-db-password" = {
          hostPath = cfg.db.passwordFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-ldap-token" = {
          hostPath = cfg.ldap.tokenFile;
          isReadOnly = true;
        };
        "/var/lib/authentik" = {
          hostPath = "/mnt/POOL/authentik";
          isReadOnly = false;
        };
        "/var/lib/authentik/media" = {
          hostPath = "/mnt/POOL/authentik/media";
          isReadOnly = false;
        };
        "/var/lib/authentik/custom-templates" = {
          hostPath = "/mnt/POOL/authentik/custom-templates";
          isReadOnly = false;
        };
      };

      config = { ... }: {
        users.users.authentik = {
          uid = lib.mkForce ids.uids.authentik;
          group = "authentik";
          isSystemUser = true;
        };
        users.groups.authentik.gid = lib.mkForce ids.gids.authentik;

        systemd.services.authentik-server = {
          description = "Authentik Server";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = cfg.db.host;
            AUTHENTIK_POSTGRESQL__PORT = toString cfg.db.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.db.name;
            AUTHENTIK_POSTGRESQL__USER = cfg.db.user;
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = toString cfg.redis.port;
          };
          serviceConfig = {
            Type = "simple";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik}/bin/ak server";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          preStart = ''
            mkdir -p /etc/authentik
            cat > /etc/authentik/config.yml << 'EOF'
            secret_key: "file:///run/secrets/authentik-secret-key"
            postgresql:
              password: "file:///run/secrets/authentik-db-password"
            bootstrap:
              admin_password: "file:///run/secrets/authentik-bootstrap-password"
            EOF
          '';
        };

        systemd.services.authentik-ldap-outpost = {
          description = "Authentik LDAP Outpost";
          wantedBy = [ "multi-user.target" ];
          after = [
            "network-online.target"
            "authentik-server.service"
          ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_HOST = "http://127.0.0.1:${toString cfg.port}";
            AUTHENTIK_TOKEN = "file:///run/secrets/authentik-ldap-token";
          };
          serviceConfig = {
            Type = "simple";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik-outposts.ldap}/bin/ldap";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };

        systemd.tmpfiles.rules = [
          "d /etc/authentik 0755 authentik authentik -"
        ];

        # Keep container alive even if authentik-server fails
        systemd.services.keep-alive = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
            Restart = "always";
          };
        };

        networking.nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        networking.defaultGateway = cfg.hostAddress;

        networking.firewall.allowedTCPPorts = [
          cfg.port
          cfg.ldap.port
        ];

        system.stateVersion = "26.11";
      };
    };

    containers.ak-worker = {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.workerHostAddress;
      localAddress = cfg.workerLocalAddress;

      bindMounts = {
        "/run/secrets/authentik-secret-key" = {
          hostPath = cfg.secretKeyFile;
          isReadOnly = true;
        };
        "/run/secrets/authentik-db-password" = {
          hostPath = cfg.db.passwordFile;
          isReadOnly = true;
        };
        "/var/lib/authentik" = {
          hostPath = "/mnt/POOL/authentik";
          isReadOnly = false;
        };
        "/var/lib/authentik/media" = {
          hostPath = "/mnt/POOL/authentik/media";
          isReadOnly = false;
        };
        "/var/lib/authentik/certs" = {
          hostPath = "/mnt/POOL/authentik/certs";
          isReadOnly = false;
        };
      };

      config = { ... }: {
        users.users.authentik = {
          uid = lib.mkForce ids.uids.authentik;
          group = "authentik";
          isSystemUser = true;
        };
        users.groups.authentik.gid = lib.mkForce ids.gids.authentik;

        systemd.services.authentik-worker = {
          description = "Authentik Worker";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = cfg.db.host;
            AUTHENTIK_POSTGRESQL__PORT = toString cfg.db.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.db.name;
            AUTHENTIK_POSTGRESQL__USER = cfg.db.user;
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = toString cfg.redis.port;
          };
          serviceConfig = {
            Type = "simple";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik}/bin/ak worker";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          preStart = ''
            mkdir -p /etc/authentik
            cat > /etc/authentik/config.yml << 'EOF'
            secret_key: "file:///run/secrets/authentik-secret-key"
            postgresql:
              password: "file:///run/secrets/authentik-db-password"
            EOF
          '';
        };

        systemd.services.authentik-beat = {
          description = "Authentik Beat Scheduler";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          environment = {
            AUTHENTIK_POSTGRESQL__HOST = cfg.db.host;
            AUTHENTIK_POSTGRESQL__PORT = toString cfg.db.port;
            AUTHENTIK_POSTGRESQL__NAME = cfg.db.name;
            AUTHENTIK_POSTGRESQL__USER = cfg.db.user;
            AUTHENTIK_REDIS__HOST = cfg.redis.host;
            AUTHENTIK_REDIS__PORT = toString cfg.redis.port;
          };
          serviceConfig = {
            Type = "simple";
            User = "authentik";
            Group = "authentik";
            WorkingDirectory = "/var/lib/authentik";
            ExecStart = "${pkgs.authentik}/bin/ak beat";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          preStart = ''
            mkdir -p /etc/authentik
            cat > /etc/authentik/config.yml << 'EOF'
            secret_key: "file:///run/secrets/authentik-secret-key"
            postgresql:
              password: "file:///run/secrets/authentik-db-password"
            EOF
          '';
        };

        systemd.tmpfiles.rules = [
          "d /etc/authentik 0755 authentik authentik -"
        ];

        networking.nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        networking.defaultGateway = cfg.workerHostAddress;

        networking.firewall.allowedTCPPorts = [ ];

        system.stateVersion = "26.11";
      };
    };

    containers.ak-redis = lib.mkIf (cfg.redis.location == "internal") {
      autoStart = true;
      extraFlags = [ "--link-journal=guest" ];
      privateNetwork = true;
      hostAddress = cfg.redisHostAddress;
      localAddress = cfg.redisLocalAddress;

      bindMounts = {
        "/var/lib/redis" = {
          hostPath = "/mnt/POOL/authentik-redis";
          isReadOnly = false;
        };
      };

      config = { ... }: {
        services.redis = {
          enable = true;
          bind = cfg.redisLocalAddress;
          port = cfg.redis.port;
        };

        networking.nameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        networking.defaultGateway = cfg.redisHostAddress;

        networking.firewall.allowedTCPPorts = [ cfg.redis.port ];

        system.stateVersion = "26.11";
      };
    };
  };
}
