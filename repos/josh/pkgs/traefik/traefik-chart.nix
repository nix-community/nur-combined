{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.5.0";
  hash = "sha256-CobsHCB/4sPYjVy5wYlRyjNf67pEuShOVcDYlVCIVmE=";

  meta = {
    description = "Helm chart for the Traefik Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
