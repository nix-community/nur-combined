{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-single";
  version = "0.43.0";
  hash = "sha256-8V9xf1DmWgS1k9UEytv743uR0EiKROUM8WzPHm3ReDs=";

  meta = {
    description = "VictoriaMetrics Single version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
