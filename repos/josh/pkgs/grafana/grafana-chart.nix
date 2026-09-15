{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://grafana-community.github.io/helm-charts";
  chart = "grafana";
  version = "13.2.5";
  hash = "sha256-oTDN0oMVCg/36Wm2VBBZmoB1I+iaEOcnEWSsgHmmYEw=";

  meta = {
    description = "Helm chart for Grafana, a tool for querying and visualizing time series and metrics";
    homepage = "https://grafana.com";
    license = lib.licenses.asl20;
  };
}
