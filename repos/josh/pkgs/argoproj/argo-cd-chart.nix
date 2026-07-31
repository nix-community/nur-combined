{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://argoproj.github.io/argo-helm/";
  chart = "argo-cd";
  version = "10.2.2";
  hash = "sha256-U89WH52NShxpzXivk+O5cC6nSs+eGBHQ0AY+ICSN+Sc=";

  meta = {
    description = "Helm chart for Argo CD, a declarative GitOps continuous delivery tool for Kubernetes";
    homepage = "https://github.com/argoproj/argo-helm";
    license = lib.licenses.asl20;
  };
}
