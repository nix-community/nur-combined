{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "prometheus";
  version = "29.27.1";
  hash = "sha256-rNR1jkw6XkelW2r4UAvqSxO5Xhq0SfWEPmAvTaRUjBY=";

  meta = {
    description = "Helm chart for Prometheus, a monitoring system and time series database";
    homepage = "https://prometheus.io";
    license = lib.licenses.asl20;
  };
}
