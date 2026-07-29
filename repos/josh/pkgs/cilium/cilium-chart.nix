{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://helm.cilium.io/";
  chart = "cilium";
  version = "1.19.6";
  hash = "sha256-WV+mKdjapuQ7dhus84C2x/0twfz9pb623NVHsfMYEaE=";

  meta = {
    description = "eBPF-based Networking, Security, and Observability";
    homepage = "https://cilium.io";
    license = lib.licenses.asl20;
  };
}
