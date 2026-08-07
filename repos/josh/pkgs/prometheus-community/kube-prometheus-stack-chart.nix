{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "kube-prometheus-stack";
  version = "88.2.0";
  hash = "sha256-nxLjmlTTI189gtfBAoh+m+g2rofvAGDJZP004Fm4C3E=";

  meta = {
    description = "Helm chart for end-to-end Kubernetes cluster monitoring with Prometheus, Grafana, and the Prometheus Operator";
    homepage = "https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack";
    license = lib.licenses.asl20;
  };
}
