{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://helm.cilium.io/";
  chart = "cilium";
  version = "1.20.2";
  hash = "sha256-B6yOW8FluRJEF+/bvVvsobW6zUhE2WYE1lprZI/s95U=";

  meta = {
    description = "Helm chart for Cilium, eBPF-based networking, observability, and security";
    homepage = "https://cilium.io";
    license = lib.licenses.asl20;
  };
}
