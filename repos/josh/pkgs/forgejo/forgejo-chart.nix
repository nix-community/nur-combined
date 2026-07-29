{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://code.forgejo.org/forgejo-helm/forgejo";
  chart = "forgejo";
  version = "17.1.3";
  hash = "sha256-ORDUEh0NkycdVPBpAcoJ4tYWgHjoJAF+3XHXwlLuPXg=";

  meta = {
    description = "Forgejo Helm chart for Kubernetes";
    homepage = "https://forgejo.org";
    license = lib.licenses.mit;
  };
}
