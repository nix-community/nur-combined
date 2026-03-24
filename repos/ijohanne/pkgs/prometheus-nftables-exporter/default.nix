{ sources, pkgs, ... }:
pkgs.buildGoModule {
  pname = "prometheus-nftables-exporter";
  version = "0.4.3";
  src = sources.nftables-exporter;
  vendorHash = "sha256-8QooGMczKUN7DjJQe5/szEYE+p0qqKqPIrVyapg/sYE=";
  doCheck = false;
  meta = {
    description = "Prometheus exporter for nftables statistics";
    homepage = "https://github.com/metal-stack/nftables-exporter";
    license = pkgs.lib.licenses.gpl3Only;
  };
}
