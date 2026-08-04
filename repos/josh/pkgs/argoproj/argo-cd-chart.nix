{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://argoproj.github.io/argo-helm/";
  chart = "argo-cd";
  version = "10.2.3";
  hash = "sha256-xnru5qhEK8rF6aXzwmYiVKdZUa0Z7kFjGxhh2dYMPFY=";

  meta = {
    description = "Helm chart for Argo CD, a declarative GitOps continuous delivery tool for Kubernetes";
    homepage = "https://github.com/argoproj/argo-helm";
    license = lib.licenses.asl20;
  };
}
