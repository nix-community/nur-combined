{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "https://isindir.github.io/sops-secrets-operator/";
  chart = "sops-secrets-operator";
  version = "0.28.1";
  hash = "sha256-CQtkd43Tmu9eT5aLzueiZYBihw9nG13ewLm9dtKTk2o=";
  helmTestArgs = [
    "--kube-version"
    "1.36.0"
  ];

  meta = {
    description = "Helm chart for the sops secrets operator, decrypting sops-encrypted Kubernetes secrets";
    homepage = "https://github.com/isindir/sops-secrets-operator";
    license = lib.licenses.mpl20;
  };
}
