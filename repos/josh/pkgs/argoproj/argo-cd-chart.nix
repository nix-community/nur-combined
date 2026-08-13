{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://argoproj.github.io/argo-helm/";
  chart = "argo-cd";
  version = "10.3.3";
  hash = "sha256-nCWlty4Lrzsej2Pz56p/IWTWpp//V59lprHvF6HtwFw=";

  meta = {
    description = "Helm chart for Argo CD, a declarative GitOps continuous delivery tool for Kubernetes";
    homepage = "https://github.com/argoproj/argo-helm";
    license = lib.licenses.asl20;
  };
}
