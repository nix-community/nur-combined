{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://argoproj.github.io/argo-helm/";
  chart = "argo-cd";
  version = "10.2.1";
  hash = "sha256-Dpi6jwyeg7WPYadd5T3Qa+puqD4ieZlkqkP/eHik2Nc=";

  meta = {
    description = "A Helm chart for Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes";
    homepage = "https://github.com/argoproj/argo-helm";
    license = lib.licenses.asl20;
  };
}
