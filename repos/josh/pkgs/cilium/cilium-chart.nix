{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://helm.cilium.io/";
  chart = "cilium";
  version = "1.20.1";
  hash = "sha256-SJXAwedwFluZGlPda7Xw19Avq2Nm9VFCsBjqVGR/em8=";

  meta = {
    description = "Helm chart for Cilium, eBPF-based networking, observability, and security";
    homepage = "https://cilium.io";
    license = lib.licenses.asl20;
  };
}
