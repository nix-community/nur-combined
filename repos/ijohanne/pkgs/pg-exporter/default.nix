{ sources, pkgs, ... }:
pkgs.buildGoModule.override { go = pkgs.go_1_26; } {
  pname = "pg-exporter";
  version = "1.2.0";
  src = sources.pg-exporter;
  vendorHash = "sha256-j5RwjJPUDh9AUYqqfvnvcDnGrykRh+6ydbaRsTutO+U=";
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/pg_exporter
    cp config/*.yml $out/share/pg_exporter/
  '';

  meta = {
    description = "Advanced PostgreSQL & Pgbouncer metrics exporter for Prometheus";
    homepage = "https://github.com/pgsty/pg_exporter";
    license = pkgs.lib.licenses.asl20;
  };
}
