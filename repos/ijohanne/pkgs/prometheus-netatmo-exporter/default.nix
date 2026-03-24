{ sources, pkgs, ... }:
pkgs.buildGoModule rec {
  name = "prometheus-netatmo-exporter";
  src = sources.netatmo-exporter;
  vendorHash = "sha256-9B74JqXDFyq10jscsFplIDrfGRRoshOd1zRBW11F33Y=";
  checkFlags = [ "-short" ];
}
