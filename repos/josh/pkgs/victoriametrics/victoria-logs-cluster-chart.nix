{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-cluster";
  version = "0.2.8";
  hash = "sha256-+sh5EOvoncIjk/Q9Ean8A7uTcQjSqmYipfQhNwZOzbg=";

  meta = {
    description = "Helm chart for deploying a VictoriaLogs cluster database in Kubernetes";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
