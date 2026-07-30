{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://quay.io/jetstack/charts/trust-manager";
  chart = "trust-manager";
  version = "0.24.0";
  hash = "sha256-4EO12NRwXnEi29AEefEwnyG6gpZGRD9wtVraPj/Xw6Y=";

  meta = {
    description = "Helm chart for trust-manager, an operator for managing TLS trust bundles in Kubernetes and OpenShift";
    homepage = "https://cert-manager.io/docs/trust/trust-manager";
    license = lib.licenses.asl20;
  };
}
