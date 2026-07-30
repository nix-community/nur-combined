{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://code.forgejo.org/forgejo-helm/forgejo";
  chart = "forgejo";
  version = "17.1.4";
  hash = "sha256-UobXxnQHV2elYUV1g4kv9yk0PRc53Z+Aqp+2Qfw9/9o=";

  meta = {
    description = "Forgejo Helm chart for Kubernetes";
    homepage = "https://forgejo.org";
    license = lib.licenses.mit;
  };
}
