{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://pkgs.tailscale.com/helmcharts";
  chart = "tailscale-operator";
  version = "1.102.3";
  hash = "sha256-yPwHKq8qXGdZlbNi9Y7fFd4PKRt0tHUTuVuh+HsyBiY=";

  meta = {
    description = "Helm chart for the Tailscale Kubernetes operator";
    homepage = "https://github.com/tailscale/tailscale";
    license = lib.licenses.bsd3;
  };
}
