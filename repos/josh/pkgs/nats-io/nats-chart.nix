{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://nats-io.github.io/k8s/helm/charts";
  chart = "nats";
  version = "2.14.2";
  hash = "sha256-X5sLK/cOg77H54rxxXENRa3WEH6uLIEkln91IU3YfuI=";

  meta = {
    description = "Helm chart for NATS, a cloud native messaging system";
    homepage = "https://github.com/nats-io/k8s";
    license = lib.licenses.asl20;
  };
}
