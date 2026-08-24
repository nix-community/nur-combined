{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/grafana/helm-charts/grafana-operator";
  chart = "grafana-operator";
  version = "5.25.0";
  hash = "sha256-ViRNz7EFkdD2Nlw6Ms79E2A+N4RPFEfWV529xWlhHx0=";

  meta = {
    description = "Helm chart for the Grafana operator, managing Grafana instances on Kubernetes";
    homepage = "https://github.com/grafana/grafana-operator";
    license = lib.licenses.asl20;
  };
}
