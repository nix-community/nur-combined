{ config, ... }:

{
  networking.ports.prometheus-exporter-zfs.enable = true;

  services.prometheus = {
    exporters.zfs = {
      enable = true;
      inherit (config.networking.ports.prometheus-exporter-zfs) port;
    };
    scrapeConfigs = [
      {
        job_name = "zfs";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.networking.ports.prometheus-exporter-zfs.port}"
            ];
          }
        ];
      }
    ];
  };
}
