{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://pkgs.tailscale.com/helmcharts";
  chart = "tailscale-operator";
  version = "1.98.9";
  hash = "sha256-Xav0I55wfaV1RbfOQP5HA2L7cU48ShJPe/Zl5JNDW8o=";

  meta = {
    description = "Helm chart for the Tailscale Kubernetes operator";
    homepage = "https://github.com/tailscale/tailscale";
    license = lib.licenses.bsd3;
  };
}
