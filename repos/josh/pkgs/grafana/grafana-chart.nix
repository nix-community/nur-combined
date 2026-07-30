{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://grafana-community.github.io/helm-charts";
  chart = "grafana";
  version = "12.10.0";
  hash = "sha256-3zaHzUQ541/1O7IV82FMQETK1Uhaq5u1cb7ZqUOgHQI=";

  meta = {
    description = "Tool for querying and visualizing time series and metrics";
    homepage = "https://grafana.com";
    license = lib.licenses.asl20;
  };
}
