{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-cluster";
  version = "0.48.0";
  hash = "sha256-hiZMbFZPj6RdqXpW6Vr4BVT6/W9pU1qnEMurYcaHIg8=";

  meta = {
    description = "Helm chart for a VictoriaMetrics cluster, a time series database and long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
