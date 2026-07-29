{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://kubernetes-sigs.github.io/external-dns/";
  chart = "external-dns";
  version = "1.21.1";
  hash = "sha256-hT2FkkhR0Lu4/5GRoEx+P8O8Q2jYiQ5rv2DLxGei7nU=";

  meta = {
    description = "ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers";
    homepage = "https://github.com/kubernetes-sigs/external-dns";
    license = lib.licenses.asl20;
  };
}
