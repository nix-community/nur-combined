{ config, ... }:

{
  networking.ports.prometheus-exporter-node_exporter.enable = true;

  services.prometheus = {
    exporters.node = {
      enable = true;
      inherit (config.networking.ports.prometheus-exporter-node_exporter) port;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };

    scrapeConfigs = [
      {
        job_name = "node_exporter";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.networking.ports.prometheus-exporter-node_exporter.port}"
            ];
          }
        ];
      }
    ];
  };

}
