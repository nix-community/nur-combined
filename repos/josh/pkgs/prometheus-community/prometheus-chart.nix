{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "prometheus";
  version = "29.27.2";
  hash = "sha256-Syz3QlBZbfBQzFTSqJ/Y8UkVwGJrkRyXv3DgAB8ccMM=";

  meta = {
    description = "Helm chart for Prometheus, a monitoring system and time series database";
    homepage = "https://prometheus.io";
    license = lib.licenses.asl20;
  };
}
