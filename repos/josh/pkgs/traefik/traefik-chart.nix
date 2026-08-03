{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.1.1";
  hash = "sha256-OmFhccOVdPUN4aHsw6mbzjJ+qtcMGM9hUBoW/p5qlb4=";

  meta = {
    description = "Helm chart for the Traefik Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
