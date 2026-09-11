{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://quay.io/jetstack/charts/cert-manager";
  chart = "cert-manager";
  version = "1.21.2";
  hash = "sha256-AsbUc4Q9aVfTmENGPPmjOwC6V6v3MpTN1cKIl8csi10=";

  meta = {
    description = "Helm chart for cert-manager, automating TLS certificate management on Kubernetes";
    homepage = "https://cert-manager.io";
    license = lib.licenses.asl20;
  };
}
