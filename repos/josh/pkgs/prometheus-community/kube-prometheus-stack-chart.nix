{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "kube-prometheus-stack";
  version = "87.21.0";
  hash = "sha256-QPUB8NLn0xT0+s3rHHJ8xkh48QrmeZ310IVflR49XJw=";

  meta = {
    description = "kube-prometheus-stack collects Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator";
    homepage = "https://github.com/prometheus-operator/kube-prometheus";
    license = lib.licenses.asl20;
  };
}
