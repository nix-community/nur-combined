{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.4.0";
  hash = "sha256-xcmiiZx4mtg92ojH6khzSq9Dl/rt8HPw9GHcyWLSUIg=";

  meta = {
    description = "Helm chart for the Traefik Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
