{
  flake.modules.nixos.immich =
    { config, lib, ... }:
    {
      vaultix.secrets.immich = { };
      services = {
        immich = {
          enable = true;
          host = "127.0.0.1";
          port = 2283;
          openFirewall = false;
          secretsFile = config.vaultix.secrets.immich.path;
          database = {
            enable = false;
            host = "/run/postgresql";
            port = 5432;
            name = "immich";
            user = "immich";
          };
          environment.DB_URL = lib.mkForce "postgresql://immich@localhost/immich?host=/run/postgresql&sslmode=disable";
          machine-learning = {
            enable = true;
            environment = {
              IMMICH_HOST = lib.mkForce "127.0.0.1";
              HF_XET_CACHE = "/var/cache/immich/huggingface-xet";
              MPLCONFIGDIR = "/var/cache/immich/mplconfig";
              HF_HUB_DISABLE_XET = "1";
            };
          };
          redis = {
            enable = false;
            host = "127.0.0.1";
            port = 6379;
          };
          settings = null;
        };
        redis.servers.immich = {
          enable = true;
          port = 0;
          unixSocket = "/run/redis-immich/redis.sock";
          unixSocketPerm = 660;
        };
        immich-public-proxy = {
          enable = true;
          immichUrl = "http://127.0.0.1:2283";
          port = 3001;
          openFirewall = false;
        };
      };

      systemd.services.immich-server = {
        after = [ "postgresql.target" ];
        requires = [ "postgresql.target" ];
        serviceConfig.BindReadOnlyPaths = [ "/run/postgresql" ];
      };
      systemd.services.immich-machine-learning.serviceConfig = {
        User = lib.mkForce "immich-ml";
        Group = lib.mkForce "immich-ml";
      };
      systemd.services.immich-public-proxy.serviceConfig.DynamicUser = lib.mkForce false;

      realm.workloads = {
        immich = {
          unit = "immich-server.service";
          user = config.services.immich.user;
          group = config.services.immich.group;
          isolation.runtimePaths = [ "/run/immich" ];
          ingress.http = {
            port = 12283;
            backend = {
              kind = "private-tcp";
              port = 2283;
            };
            service = "immich";
            allow.identities = config.realm.caddy.allowedIDs.immich ++ [
              "spiffe://nyaw.xyz/service/immich-public-proxy"
            ];
          };
          egress = {
            redis = {
              service = "redis-immich";
              localPort = 6379;
            };
            ml = {
              service = "immich-ml";
              localPort = 3003;
            };
          };
        };
        redis-immich = {
          isolation.runtimePaths = [ "/run/redis-immich" ];
          ingressGroups = [ "redis-immich" ];
          ingress.redis = {
            port = 16380;
            backend = {
              kind = "unix";
              path = "/run/redis-immich/redis.sock";
            };
            service = "redis-immich";
            allow.workloads = [ "immich" ];
          };
        };
        immich-ml = {
          unit = "immich-machine-learning.service";
          ingress.http = {
            port = 13003;
            backend = {
              kind = "private-tcp";
              port = 3003;
            };
            service = "immich-ml";
            allow.workloads = [ "immich" ];
          };
          http.internet = true;
        };
        immich-public-proxy = {
          user = "ipp";
          group = "ipp";
          ingress.http = {
            port = 13001;
            backend = {
              kind = "private-tcp";
              port = 3001;
            };
            service = "immich-public-proxy";
            allow.identities = config.realm.caddy.allowedIDs.immich-public-proxy;
          };
          egress.immich = {
            service = "immich";
            localPort = 2283;
          };
        };
      };
    };
}
