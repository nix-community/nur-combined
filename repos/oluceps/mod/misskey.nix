{
  flake.modules.nixos.misskey =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ ../nixosModules/realm-agent.nix ];
      vaultix.secrets.misskey = {
        owner = "misskey";
        mode = "400";
      };
      services.redis.servers.misskey = {
        enable = true;
        port = 0;
      };
      realm.workloads = {
        misskey = {
          unit = "podman-misskey.service";
          runtime = "container";
          transparent = {
            dnsHosts."s3.nyaw.xyz" = [ "127.0.0.1" ];
          };
          container = {
            name = "misskey";
            backendPath = "/run/realm-misskey/backend";
            extraRoutes = [
              {
                port = 5432;
                socket = "/run/postgresql/.s.PGSQL.5432";
              }
            ];
          };
          ingressGroups = [ "misskey" ];
          ingress.http = {
            port = 13012;
            backend = {
              kind = "unix";
              path = "/run/realm-misskey/backend/http.sock";
            };
            service = "misskey";
            allow.identities = config.realm.caddy.allowedIDs.misskey;
          };
          egress = {
            redis = {
              service = "redis-misskey";
              localPort = 6379;
            };
            meilisearch = {
              service = "meilisearch";
              localPort = 7700;
            };
            s3 = {
              service = "https-gateway";
              localPort = 443;
            };
            internet = {
              service = "internet-proxy";
              localPort = 13128;
            };
          };
        };
        redis-misskey = {
          isolation.runtimePaths = [ "/run/redis-misskey" ];
          ingressGroups = [ "redis-misskey" ];
          ingress.redis = {
            port = 16379;
            backend = {
              kind = "unix";
              path = "/run/redis-misskey/redis.sock";
            };
            service = "redis-misskey";
            allow.workloads = [ "misskey" ];
          };
        };
      };
      systemd.tmpfiles.rules = [
        "d /run/realm-misskey 0750 misskey realm-misskey -"
        "d /run/realm-misskey/backend 0750 misskey misskey -"
      ];
      users = {
        groups.misskey = { };
        users.misskey = {
          isSystemUser = true;
          group = "misskey";
          home = "/var/lib/misskey";
          linger = true;
          createHome = true;
          uid = 984;
          subUidRanges = [
            {
              count = 65536;
              startUid = 2147483646;
            }
          ];
          subGidRanges = [
            {
              count = 65536;
              startGid = 2147483647;
            }
          ];
        };
      };

      systemd.services.podman-misskey = {
        after = [
          "network-online.target"
          "postgresql.target"
        ];
        requires = [ "postgresql.target" ];
        wants = [ "network-online.target" ];
      };
      virtualisation.oci-containers = {
        containers.misskey = {
          volumes =
            let
              cabundle = pkgs.cacert.override {
                extraCertificateFiles = with config.fn.pki; [
                  root_file
                ];
              };
            in
            [
              "${config.vaultix.secrets.misskey.path}:/misskey/.config/default.yml:ro"
              "${cabundle}/etc/ssl/certs/ca-bundle.crt:/misskey/ca.crt:ro"
              "${cabundle}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt"
              "/run/postgresql:/run/postgresql:ro"
            ];
          # pull = "always";
          image = "misskey/misskey:latest";
          networks = [ "none" ];
          user = "1000:1000";
          # The image's tini entrypoint stays in place; tini runs the adapter,
          # which publishes the local sockets and then runs the migrate command.
          cmd = [
            "/realm/helper"
            "launch"
            "pnpm"
            "run"
            "migrateandstart"
          ];
          extraOptions = [
            "--add-host=s3.nyaw.xyz:127.0.0.1"
            "--userns=keep-id:uid=1000,gid=1000"
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
            "--sysctl=net.ipv4.ip_unprivileged_port_start=0"
            "--health-cmd=node /realm/health.cjs"
            "--health-interval=30s"
            "--health-start-period=120s"
          ];
          podman = {
            user = "misskey";
            sdnotify = "healthy";
          };

          environment = {
            MISSKEY_CONFIG_YML = "default.yml";
            NODE_EXTRA_CA_CERTS = "/misskey/ca.crt";
          };
        };
      };
    };
}
