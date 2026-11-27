{ config, lib, ... }:
let
  inherit (lib) mkIf;

  # Constant across every node, matching nut_exporter's upstream default. Not
  # 3493: that is upsd's port and would collide on NUT servers.
  exporterPort = 9199;
in
{
  # Bring the NUT exporter up wherever NUT is enabled. Deliberately leaves
  # openFirewall off: the exporter listens on 0.0.0.0 but exposing it is up to
  # whoever scrapes it. Netclient hosts have no local upsd to scrape.
  config = mkIf config.power.ups.enable {
    services.prometheus.exporters.nut = {
      enable = config.power.ups.mode != "netclient";
      port = exporterPort;
      nutServer = "127.0.0.1";
    };
  };
}
