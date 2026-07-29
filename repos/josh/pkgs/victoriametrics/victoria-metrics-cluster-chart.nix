{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-cluster";
  version = "0.47.0";
  hash = "sha256-Yfcg1sMVkAJLFysoWaEEDxAaZPmdIU5/lflUc2lrGtU=";

  meta = {
    description = "VictoriaMetrics Cluster version - high-performance, cost-effective and scalable TSDB, long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
