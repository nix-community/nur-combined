{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://kubernetes-sigs.github.io/metrics-server/";
  chart = "metrics-server";
  version = "3.13.1";
  hash = "sha256-rKNrjRauYdg9tfW3Y3oA48UqcsFsApK6Z5k/3rglxss=";

  meta = {
    description = "Helm chart for Metrics Server, a source of container resource metrics for Kubernetes autoscaling";
    homepage = "https://github.com/kubernetes-sigs/metrics-server";
    license = lib.licenses.asl20;
  };
}
