{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-single";
  version = "0.45.0";
  hash = "sha256-PudufXF+x6m+RAzkb7B8wqNqTlLz+t6BPwoPgb0r5o8=";

  meta = {
    description = "Helm chart for single-node VictoriaMetrics, a time series database and long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
