{
  flake.modules.nixos.telegram-search =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cabundle = pkgs.cacert.override {
        extraCertificateFiles = [ config.fn.pki.root_file ];
      };
    in
    {
      imports = [ ../nixosModules/realm-container.nix ];
      vaultix.secrets.tg-search = {
        owner = "telegram-search";
        mode = "400";
      };
      users.groups.telegram-search = { };
      users.users.telegram-search = {
        isSystemUser = true;
        uid = 1983;
        group = "telegram-search";
        home = "/var/lib/telegram-search";
        createHome = true;
        linger = true;
        subUidRanges = [
          {
            startUid = 2147614720;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 2147614720;
            count = 65536;
          }
        ];
      };
      systemd.tmpfiles.rules = [
        "d /run/realm-telegram-search 0750 telegram-search realm-telegram-search -"
        "d /run/realm-telegram-search/backend 0750 telegram-search telegram-search -"
        "d /var/lib/tg-search 0700 telegram-search telegram-search -"
        "d /var/lib/tg-search/data 0700 telegram-search telegram-search -"
      ];
      # Existing rootful deployment data moves to the rootless container owner once.
      systemd.services.telegram-search-data-owner = {
        before = [ "podman-telegram-search-app.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          if [ ! -e /var/lib/telegram-search/.data-owner-migrated ]; then
            ${pkgs.coreutils}/bin/chown -R --no-dereference telegram-search:telegram-search /var/lib/tg-search
            ${pkgs.coreutils}/bin/touch /var/lib/telegram-search/.data-owner-migrated
          fi
        '';
      };
      realm.workloads.telegram-search = {
        unit = "podman-telegram-search-app.service";
        runtime = "container";
        container = {
          name = "telegram-search-app";
          backendPath = "/run/realm-telegram-search/backend";
        };
        ingressGroups = [ "telegram-search" ];
        socksProxy.enable = true;
        ingress.http = {
          port = 13336;
          backend = {
            kind = "unix";
            path = "/run/realm-telegram-search/backend/http.sock";
          };
          service = "telegram-search";
          allow.identities = [ "spiffe://nyaw.xyz/service/caddy" ];
        };
        egress = {
          postgresql = {
            service = "postgresql-telegram-search";
            localPort = 15432;
          };
          s3 = {
            service = "https-gateway";
            verifyID = "spiffe://nyaw.xyz/service/caddy";
            localPort = 443;
          };
          internet = {
            service = "internet-proxy";
            localPort = 13128;
          };
        };
      };
      virtualisation.oci-containers.containers.telegram-search-app = {
        image = "ghcr.io/groupultra/telegram-search:latest";
        networks = [ "none" ];
        user = "0:0";
        podman.user = "telegram-search";
        podman.sdnotify = "healthy";
        # The helper replaces the image entrypoint: it publishes the loopback
        # adapters and the ingress socket, then runs the real command.
        entrypoint = "/realm/helper";
        cmd = [
          "launch"
          "/bin/sh"
          "-c"
          "mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs; exec /bin/sh /entrypoint.sh"
        ];
        volumes = [
          "${cabundle}/etc/ssl/certs/ca-bundle.crt:/search/ca.crt:ro"
          "${cabundle}/etc/ssl/certs/ca-bundle.crt:/etc/ssl/certs/ca-certificates.crt:ro"
          "/var/lib/tg-search/data:/app/data:rw"
        ];
        extraOptions = [
          "--userns=keep-id:uid=0,gid=0"
          "--cap-drop=ALL"
          # The image starts nginx as namespace-root, then drops worker privileges.
          "--cap-add=CHOWN,SETUID,SETGID"
          # The image owns these paths as nginx:nginx mode 0750; namespace-root
          # has no DAC override. Give nginx disposable writable runtime directories.
          "--tmpfs=/var/lib/nginx:rw,nosuid,nodev,noexec,mode=0755,notmpcopyup"
          "--tmpfs=/var/log/nginx:rw,nosuid,nodev,noexec,mode=0755,notmpcopyup"
          "--security-opt=no-new-privileges"
          "--sysctl=net.ipv4.ip_unprivileged_port_start=0"
          "--add-host=s3.nyaw.xyz:127.0.0.1"
          "--health-cmd=node /realm/health.cjs"
          "--health-interval=30s"
          "--health-start-period=120s"
        ];
        environment = {
          NODE_EXTRA_CA_CERTS = "/search/ca.crt";
          NODE_USE_ENV_PROXY = "1";
          HTTP_PROXY = "http://127.0.0.1:13128";
          HTTPS_PROXY = "http://127.0.0.1:13128";
          NO_PROXY = "localhost,127.0.0.1,::1,s3.nyaw.xyz";
          PROXY_URL = "socks5://127.0.0.1:11080";
          DATABASE_URL = "postgresql://telegram_search@127.0.0.1:15432/telegram_search?sslmode=disable";
          TELEGRAM_API_ID = "611335";
          TELEGRAM_API_HASH = "d524b414d21f4d37f08684c1df41ac9c";
          MINIO_URL = "https://s3.nyaw.xyz";
          MINIO_BUCKET = "telegram-search";
          HOST = "127.0.0.1";
          REALM_INGRESS_PORT = "3333";
          REALM_HEALTH_PORT = "3000";
        };
        environmentFiles = [ config.vaultix.secrets.tg-search.path ];
      };
      systemd.services.podman-telegram-search-app = {
        requires = [ "telegram-search-data-owner.service" ];
        after = [ "telegram-search-data-owner.service" ];
        serviceConfig.Restart = lib.mkOverride 90 "always";
      };
    };
}
