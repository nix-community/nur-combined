{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-k8s-stack";
  version = "0.89.0";
  hash = "sha256-ZzbM5d6bl/nmUXxOL4JR1cCGt3AGj/VdriVpKhJH7tU=";

  meta = {
    description = "Helm chart for Kubernetes monitoring with the VictoriaMetrics operator, Grafana dashboards, ServiceScrapes and VMRules";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
