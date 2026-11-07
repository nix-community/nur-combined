{
  config,
  lib,
  ...
}:
{
  options.services.monitoring.tempo = {
    enable = lib.mkEnableOption "Tempo distributed tracing backend";
  };

  config = lib.mkIf config.services.monitoring.tempo.enable {
    services.tempo = {
      enable = true;
      settings = {
        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = 3200;
          grpc_listen_port = 9096;
        };

        distributor.receivers = {
          otlp.protocols = {
            grpc.endpoint = "0.0.0.0:4317";
            http.endpoint = "0.0.0.0:4318";
          };
        };

        storage.trace = {
          backend = "local";
          local.path = "/var/lib/tempo/traces";
          wal.path = "/var/lib/tempo/wal";
        };

        compactor = {
          compaction = {
            block_retention = "336h"; # 14 days, matching Loki
          };
        };

        metrics_generator = {
          registry.external_labels = {
            source = "tempo";
          };
          storage = {
            path = "/var/lib/tempo/generator/wal";
            remote_write = [
              { url = "http://localhost:9090/api/v1/write"; }
            ];
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      3200 # Tempo HTTP API (query)
      4317 # OTLP gRPC receiver
      4318 # OTLP HTTP receiver
    ];
  };
}
