{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.3.0";
  hash = "sha256-pGDOxl9svr28aZiZ7UQX0pR6TzwZFkf+xVXYJyzh+vU=";

  meta = {
    description = "Helm chart for the Traefik Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
