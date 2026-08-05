{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://victoriametrics.github.io/helm-charts";
  chart = "victoria-metrics-single";
  version = "0.44.0";
  hash = "sha256-KZBoDDrm0uw8W/W3R52x+OTQolumgBRD30C4rYCjXGk=";

  meta = {
    description = "Helm chart for single-node VictoriaMetrics, a time series database and long-term remote storage for Prometheus";
    homepage = "https://github.com/VictoriaMetrics/helm-charts";
    license = lib.licenses.asl20;
  };
}
