{
  config,
  lib,
  homelab,
  ...
}:
{
  options.services.monitoring.loki = {
    enable = lib.mkEnableOption "Loki log aggregation server";
  };

  config = lib.mkIf config.services.monitoring.loki.enable {
    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;

        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 3101;
        };

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/var/lib/loki";
        };

        schema_config.configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        storage_config.filesystem.directory = "/var/lib/loki/chunks";

        limits_config = {
          retention_period = "336h";
          allow_structured_metadata = false;
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          delete_request_cancel_period = "10m";
          retention_delete_delay = "2h";
        };
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."loki-gateway" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 3100;
          }
        ];
        locations."/" = {
          proxyPass = "http://127.0.0.1:3101";
          extraConfig = ''
            allow 127.0.0.1;
            allow 10.1.0.0/24;
            allow 10.100.0.0/24;
            deny all;

            proxy_set_header X-Scope-OrgID $http_x_scope_orgid;
          '';
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 3100 ];
  };
}
