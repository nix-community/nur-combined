{
  flake.modules.nixos.ncps =
    { config, ... }:
    {
      vaultix.secrets.ncps = {
        owner = "ncps";
        mode = "400";
      };
      systemd.services.ncps = {
        requires = [
          "seaweedfs.service"
          "postgresql.service"
        ];
        after = [ "postgresql.service" ];
        serviceConfig = {
          EnvironmentFile = config.vaultix.secrets.ncps.path;
        };
      };
      realm.observability.endpoints.ncps.socket = "/run/realm/observability/egress/ncps.sock";
      realm.workloads.observability.egress.ncps = {
        service = "ncps-metrics";
      };
      realm.workloads.ncps = {
        http = {
          internet = true;
          gateway = {
            ref = "eihort";
            resolveHosts = [ "s3.nyaw.xyz" ];
          };
        };
        isolation = {
          runtimePaths = [ "/run/ncps" ];
          allowUnixSockets = [ "/run/postgresql" ];
        };
        ingress = {
          http = {
            port = 18501;
            backend = {
              kind = "private-tcp";
              port = 8501;
            };
            service = "ncps";
            allow.identities = [ "spiffe://nyaw.xyz/service/nix-cache" ];
          };
          metrics = {
            port = 19501;
            backend = {
              kind = "private-tcp";
              port = 8501;
            };
            service = "ncps-metrics";
            allow.identities = [ "spiffe://nyaw.xyz/service/observability-${config.networking.hostName}" ];
          };
        };
      };
      services.ncps = {
        enable = true;
        cache = {
          hostName = "cache.nyaw.xyz";
          maxSize = "200G";
          lru.schedule = "0 2 * * *";
          databaseURL = "postgresql:///ncps?host=/run/postgresql";
          storage.s3 = {
            bucket = "ncps";
            endpoint = "https://s3.nyaw.xyz";
            region = "ap-east-1";
            forcePathStyle = true;
          };
          upstream = {
            urls = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://devenv.cachix.org"
            ];
            publicKeys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
          };
        };
        prometheus.enable = true;
        server.addr = "127.0.0.1:8501";
      };
    };
}
