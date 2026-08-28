{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://nats-io.github.io/k8s/helm/charts";
  chart = "nats";
  version = "2.14.6";
  hash = "sha256-ZXhn35xsG3FNTducioZnrWvW0LA/jS4ePeYSmCGfLxU=";

  meta = {
    description = "Helm chart for NATS, a cloud native messaging system";
    homepage = "https://github.com/nats-io/k8s";
    license = lib.licenses.asl20;
  };
}
