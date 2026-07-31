{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.external-secrets.io/";
  chart = "external-secrets";
  version = "2.8.0";
  hash = "sha256-PPUhkWM5kZSRKwuBLFrEt1cnxtfelj9QGfaEsHUzu5g=";

  meta = {
    description = "Helm chart for the External Secrets Operator, integrating external secret management systems with Kubernetes";
    homepage = "https://github.com/external-secrets/external-secrets";
    license = lib.licenses.asl20;
  };
}
