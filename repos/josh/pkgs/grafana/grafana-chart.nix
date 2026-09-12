{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://grafana-community.github.io/helm-charts";
  chart = "grafana";
  version = "13.2.4";
  hash = "sha256-0dqfbXMzaO6V5XgL5fDHd6Nc7fJaCoVWf1pvDPGIae0=";

  meta = {
    description = "Helm chart for Grafana, a tool for querying and visualizing time series and metrics";
    homepage = "https://grafana.com";
    license = lib.licenses.asl20;
  };
}
