{ lib, nur }:
nur.repos.josh.fetchhelm {
  pname = "cloudnative-pg-cluster-chart";
  url = "https://cloudnative-pg.github.io/charts";
  chart = "cluster";
  version = "0.8.1";
  hash = "sha256-4wo9gq9GHZ6QLgcdEuQek2TyQoWVki/0F4k+slAeXFc=";

  meta = {
    description = "Deploys and manages a CloudNativePG cluster and its associated resources";
    homepage = "https://cloudnative-pg.io";
    license = lib.licenses.asl20;
  };
}
