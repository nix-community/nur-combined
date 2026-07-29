{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-logs-single";
  version = "0.13.9";
  hash = "sha256-XmhUsFnYNEEuCywXrHrhaMycALRTkZyluzhWwT8F7IM=";

  meta = {
    description = "The VictoriaLogs single Helm chart deploys VictoriaLogs database in Kubernetes";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
