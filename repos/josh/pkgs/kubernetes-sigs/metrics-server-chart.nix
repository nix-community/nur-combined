{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://kubernetes-sigs.github.io/metrics-server/";
  chart = "metrics-server";
  version = "3.14.0";
  hash = "sha256-6MRrUlscZAn2c7SK9u+GtwgpWLAp5Lph49djpJwahdg=";

  meta = {
    description = "Helm chart for Metrics Server, a source of container resource metrics for Kubernetes autoscaling";
    homepage = "https://github.com/kubernetes-sigs/metrics-server";
    license = lib.licenses.asl20;
  };
}
