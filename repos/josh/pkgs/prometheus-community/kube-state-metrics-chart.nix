{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://prometheus-community.github.io/helm-charts";
  chart = "kube-state-metrics";
  version = "8.4.2";
  hash = "sha256-/dH+0kdZlb76pnJ0zQNhfNEmTlk4JvMXccpRoqx/hfg=";

  meta = {
    description = "Helm chart for kube-state-metrics, which generates and exposes cluster-level metrics";
    homepage = "https://github.com/kubernetes/kube-state-metrics";
    license = lib.licenses.asl20;
  };
}
