{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://grafana-community.github.io/helm-charts";
  chart = "grafana";
  version = "12.10.4";
  hash = "sha256-4W2uoTf0is7xtFjHUJ1S86jE1oFsf9H4PL1dQolYvXE=";

  meta = {
    description = "Helm chart for Grafana, a tool for querying and visualizing time series and metrics";
    homepage = "https://grafana.com";
    license = lib.licenses.asl20;
  };
}
