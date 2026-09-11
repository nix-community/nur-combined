{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://quay.io/jetstack/charts/trust-manager";
  chart = "trust-manager";
  version = "0.25.0";
  hash = "sha256-M4XHIa8bvIF69pFYsYcR4IpRERg2BpxAfjAY00LFzbM=";

  meta = {
    description = "Helm chart for trust-manager, an operator for managing TLS trust bundles in Kubernetes and OpenShift";
    homepage = "https://cert-manager.io/docs/trust/trust-manager";
    license = lib.licenses.asl20;
  };
}
