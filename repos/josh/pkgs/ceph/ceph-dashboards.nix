{
  lib,
  stdenvNoCC,
  ceph,
  jq,
  prometheus,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ceph-dashboards";
  inherit (ceph) version src;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/dashboards $out/alerts
    cp -R ./monitoring/ceph-mixin/dashboards_out/* $out/dashboards/
    cp ./monitoring/ceph-mixin/prometheus_alerts.yml $out/alerts/ceph_alerts.yml

    runHook postInstall
  '';

  passthru.tests = {
    json =
      runCommand "test-ceph-dashboards-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
          readarray -t files < <(find ${finalAttrs.finalPackage} -name '*.json')
          [ "''${#files[@]}" -gt 0 ]
          jq --exit-status . "''${files[@]}" >/dev/null
          touch $out
        '';

    alerts =
      runCommand "test-ceph-dashboards-alerts"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ prometheus.cli ];
        }
        ''
          promtool check rules ${finalAttrs.finalPackage}/alerts/ceph_alerts.yml
          touch $out
        '';
  };

  meta = {
    description = "Grafana dashboards and Prometheus alerts from the Ceph mixin";
    inherit (ceph.meta) homepage license;
    platforms = lib.platforms.all;
  };
})
