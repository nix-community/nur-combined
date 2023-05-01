{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.woodpecker;
in
{
  config = lib.mkIf cfg.enable {
    services.woodpecker-server = {
      enable = true;

      package = pkgs.ambroisie.woodpecker-server;

      environment = {
        WOODPECKER_OPEN = "true";
        WOODPECKER_HOST = "https://woodpecker.${config.networking.domain}";
        WOODPECKER_DATABASE_DRIVER = "postgres";
        WOODPECKER_DATABASE_DATASOURCE = "postgres:///woodpecker?host=/run/postgresql";
        WOODPECKER_ADMIN = "${cfg.admin}";
        WOODPECKER_SERVER_ADDR = ":${toString cfg.port}";
        WOODPECKER_GRPC_ADDR = ":${toString cfg.rpcPort}";

        WOODPECKER_GITEA = "true";
        WOODPECKER_GITEA_URL = config.services.gitea.settings.server.ROOT_URL;

        WOODPECKER_LOG_LEVEL = "debug";
      };
    };

    systemd.services.woodpecker-server = {
      serviceConfig = {
        # Set username for DB access
        User = "woodpecker";

        BindPaths = [
          # Allow access to DB path
          "/run/postgresql"
        ];

        EnvironmentFile = [
          cfg.secretFile
          cfg.sharedSecretFile
        ];
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "woodpecker" ];
      ensureUsers = [{
        name = "woodpecker";
        ensurePermissions = {
          "DATABASE woodpecker" = "ALL PRIVILEGES";
        };
      }];
    };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "woodpecker";
        inherit (cfg) port;
      }
      # I might want to be able to RPC from other hosts in the future
      {
        subdomain = "woodpecker-rpc";
        port = cfg.rpcPort;
      }
    ];
  };
}
