{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://quay.io/jetstack/charts/cert-manager";
  chart = "cert-manager";
  version = "1.21.1";
  hash = "sha256-7OgOm+kDjwAow9EoWM+5XPNmrNte+zxhZq3ZHSf2aqc=";

  meta = {
    description = "Helm chart for cert-manager, automating TLS certificate management on Kubernetes";
    homepage = "https://cert-manager.io";
    license = lib.licenses.asl20;
  };
}
