{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "kube-prometheus-stack";
  version = "88.0.1";
  hash = "sha256-uni5p/32zlKzhSXS7ysrXOAk1heh7vMxzUVypjHi66U=";

  meta = {
    description = "Helm chart for end-to-end Kubernetes cluster monitoring with Prometheus, Grafana, and the Prometheus Operator";
    homepage = "https://github.com/prometheus-operator/kube-prometheus";
    license = lib.licenses.asl20;
  };
}
