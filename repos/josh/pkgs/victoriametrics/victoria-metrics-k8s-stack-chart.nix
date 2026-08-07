{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-k8s-stack";
  version = "0.90.1";
  hash = "sha256-k8VBJFqu8nNw2t0IjCdBPzphEiLRvAzAF7ZqwYVMqZQ=";

  meta = {
    description = "Helm chart for Kubernetes monitoring with the VictoriaMetrics operator, Grafana dashboards, ServiceScrapes and VMRules";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
