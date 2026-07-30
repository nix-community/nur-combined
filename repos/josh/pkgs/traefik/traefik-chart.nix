{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.1.0";
  hash = "sha256-+WgOFqk18C7A34u0w5vRJR9kD1UJTG2k5asPJ1qOZKg=";

  meta = {
    description = "A Traefik based Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
