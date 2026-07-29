{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://quay.io/jetstack/charts/cert-manager";
  chart = "cert-manager";
  version = "1.21.0";
  hash = "sha256-QRNY61ZvZkC8vtKv5Ng8Zb+vkt109OnUHRB/CYiSYR4=";

  meta = {
    description = "A Helm chart for cert-manager";
    homepage = "https://cert-manager.io";
    license = lib.licenses.asl20;
  };
}
