{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.2.0";
  hash = "sha256-HBxIhELOwWvH6kA7f4ibiOYAWZ2E9likLVaxlUSZmEg=";

  meta = {
    description = "Helm chart for the Traefik Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
