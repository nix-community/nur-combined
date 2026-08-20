{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "kube-prometheus-stack";
  version = "88.5.2";
  hash = "sha256-DpSuAKYWEkBA0btY1/2dcv4UWAi3G7vEZPGDToQyVKU=";

  meta = {
    description = "Helm chart for end-to-end Kubernetes cluster monitoring with Prometheus, Grafana, and the Prometheus Operator";
    homepage = "https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack";
    license = lib.licenses.asl20;
  };
}
