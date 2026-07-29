{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://kubernetes-sigs.github.io/headlamp/";
  chart = "headlamp";
  version = "0.44.0";
  hash = "sha256-WJ+feSnsvWwJkx4K9jL2OKotFfRAV72c5zYddQzv5h8=";

  meta = {
    description = "Headlamp is an easy-to-use and extensible Kubernetes web UI";
    homepage = "https://headlamp.dev";
    license = lib.licenses.asl20;
  };
}
