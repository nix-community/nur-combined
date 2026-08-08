{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://charts.external-secrets.io/";
  chart = "external-secrets";
  version = "2.9.0";
  hash = "sha256-inifdz966W6XeZWf4a3AqkM+HWvTfMbD6leqD7Qn+04=";

  meta = {
    description = "Helm chart for the External Secrets Operator, integrating external secret management systems with Kubernetes";
    homepage = "https://github.com/external-secrets/external-secrets";
    license = lib.licenses.asl20;
  };
}
