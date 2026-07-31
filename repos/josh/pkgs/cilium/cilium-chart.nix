{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://helm.cilium.io/";
  chart = "cilium";
  version = "1.20.0";
  hash = "sha256-SlLnegSpa8y1zOX4rjGG1S7lB5hofW3EGaKBsJoz7Fc=";

  meta = {
    description = "Helm chart for Cilium, eBPF-based networking, observability, and security";
    homepage = "https://cilium.io";
    license = lib.licenses.asl20;
  };
}
