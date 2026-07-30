{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "prometheus";
  version = "29.20.1";
  hash = "sha256-g6PPZmVBR6WS4YjbnD4dUP+LsqgkR99bslKIIQG9c2g=";

  meta = {
    description = "Helm chart for Prometheus, a monitoring system and time series database";
    homepage = "https://prometheus.io";
    license = lib.licenses.asl20;
  };
}
