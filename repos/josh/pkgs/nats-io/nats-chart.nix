{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://nats-io.github.io/k8s/helm/charts";
  chart = "nats";
  version = "2.14.4";
  hash = "sha256-jTG4ce2LidtZ35hM4VjfMghbzc3Ji2dirwtBNM4eJCI=";

  meta = {
    description = "Helm chart for NATS, a cloud native messaging system";
    homepage = "https://github.com/nats-io/k8s";
    license = lib.licenses.asl20;
  };
}
