{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://grafana-community.github.io/helm-charts";
  chart = "grafana";
  version = "13.2.1";
  hash = "sha256-yOlUJjtPor7V7rNVU+p6G1ptER9CohAExVLsPU1Zcwg=";

  meta = {
    description = "Helm chart for Grafana, a tool for querying and visualizing time series and metrics";
    homepage = "https://grafana.com";
    license = lib.licenses.asl20;
  };
}
