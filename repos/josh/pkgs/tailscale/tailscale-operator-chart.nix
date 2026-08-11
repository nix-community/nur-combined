{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://pkgs.tailscale.com/helmcharts";
  chart = "tailscale-operator";
  version = "1.102.2";
  hash = "sha256-5P+0kv5Hc8/1V7llyo3hb1/mJNew6yK7FeHgfgetXBg=";

  meta = {
    description = "Helm chart for the Tailscale Kubernetes operator";
    homepage = "https://github.com/tailscale/tailscale";
    license = lib.licenses.bsd3;
  };
}
