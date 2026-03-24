{ sources, pkgs, ... }:
pkgs.buildGoModule rec {
  name = "prometheus-teamspeak3-exporter";
  src = sources.ts3exporter;
  vendorHash = "sha256-7t3eoICAetRHnzdMzRvDSFjGPvBV/rSgvGHH7UntX5Y=";
  checkFlags = [ "-short" ];
}
