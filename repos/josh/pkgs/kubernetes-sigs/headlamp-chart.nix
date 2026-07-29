{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://kubernetes-sigs.github.io/headlamp/";
  chart = "headlamp";
  version = "0.43.0";
  hash = "sha256-Z0HQy7Mr0CRIzj1TluPJH04VHr912dzsYpWyKdZjUUc=";

  meta = {
    description = "Headlamp is an easy-to-use and extensible Kubernetes web UI";
    homepage = "https://headlamp.dev";
    license = lib.licenses.asl20;
  };
}
