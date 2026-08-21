{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://kubernetes-sigs.github.io/headlamp/";
  chart = "headlamp";
  version = "0.45.0";
  hash = "sha256-hJKCelyNZiOT9DckD+UOpCVWNMsxH5y+V9If376TNx4=";

  meta = {
    description = "Helm chart for Headlamp, an extensible Kubernetes web UI";
    homepage = "https://headlamp.dev";
    license = lib.licenses.asl20;
  };
}
