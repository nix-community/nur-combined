{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-single";
  version = "0.46.0";
  hash = "sha256-OXSpS8EOjJPq3mjZI265hkwfI4QT1YluYdDH6n2OZDk=";

  meta = {
    description = "Helm chart for single-node VictoriaMetrics, a time series database and long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
