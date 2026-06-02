{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://metallb.github.io/metallb/";
  chart = "metallb";
  version = "0.16.1";
  sha256 = "sha256-Z1qB6M5XxM3VXkYBzgDOjGLaoR7ICzffXT4OaDruP8k=";
  helmTestValues = {
    "frr-k8s".prometheus.serviceMonitor.enabled = false;
  };
}
