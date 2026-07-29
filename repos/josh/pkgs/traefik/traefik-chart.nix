{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://traefik.github.io/charts/";
  chart = "traefik";
  version = "41.0.2";
  hash = "sha256-MZTu+K9INGWXqkm7UMxI1UzbU92sy4S5qtqb0NZ3gAY=";

  meta = {
    description = "A Traefik based Kubernetes ingress controller";
    homepage = "https://traefik.io";
    license = lib.licenses.asl20;
  };
}
