{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-cluster";
  version = "0.49.0";
  hash = "sha256-CN9KXHpYzvV1mj2R79ubbnzyx93d3bl0qQ3UXr166rI=";

  meta = {
    description = "Helm chart for a VictoriaMetrics cluster, a time series database and long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
