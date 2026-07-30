{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://nats-io.github.io/k8s/helm/charts";
  chart = "nack";
  version = "0.34.0";
  hash = "sha256-MgEh3svpWxtHfC6JNE/kkF/ddzDg2onua2RaQEddh0U=";

  meta = {
    description = "Helm chart for NACK, the NATS controller for Kubernetes";
    homepage = "https://github.com/nats-io/k8s";
    license = lib.licenses.asl20;
  };
}
