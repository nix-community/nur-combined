{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://argoproj.github.io/argo-helm/";
  chart = "argo-cd";
  version = "10.9.1";
  hash = "sha256-5rwM9ERbAqHI3ov2c0xHmt9xlKsevedstr8AJiTqX04=";

  meta = {
    description = "Helm chart for Argo CD, a declarative GitOps continuous delivery tool for Kubernetes";
    homepage = "https://github.com/argoproj/argo-helm";
    license = lib.licenses.asl20;
  };
}
