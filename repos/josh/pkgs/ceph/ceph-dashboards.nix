{
  lib,
  stdenvNoCC,
  ceph,
}:
stdenvNoCC.mkDerivation {
  pname = "ceph-dashboards";
  inherit (ceph) version src;

  installPhase = ''
    mkdir -p $out/dashboards $out/alerts
    cp -R ./monitoring/ceph-mixin/dashboards_out/* $out/dashboards/
    cp ./monitoring/ceph-mixin/prometheus_alerts.yml $out/alerts/ceph_alerts.yml
  '';

  meta = {
    description = "Ceph Grafana Dashboards";
    inherit (ceph.meta) homepage license;
    platforms = lib.platforms.all;
  };
}
