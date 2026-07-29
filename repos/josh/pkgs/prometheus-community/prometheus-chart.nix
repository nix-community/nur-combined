{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "prometheus";
  version = "29.20.0";
  hash = "sha256-xEF8LuR5ICp9rJQdFinXf0DP5b7y5KdLZHNgtQl7CxM=";

  meta = {
    description = "Prometheus is a monitoring system and time series database";
    homepage = "https://prometheus.io";
    license = lib.licenses.asl20;
  };
}
