{ lib, config, ... }:
let
  cfg = config.services.metrics;
in
{
  options.services.metrics.enable = lib.mkEnableOption "export server metrics";
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "arp" ];
      };
      chrony = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
    };
    realm.observability.endpoints = {
      node.port = config.services.prometheus.exporters.node.port;
      chrony.port = config.services.prometheus.exporters.chrony.port;
    };
  };
}
