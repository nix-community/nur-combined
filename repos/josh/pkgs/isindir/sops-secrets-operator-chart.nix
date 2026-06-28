{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://isindir.github.io/sops-secrets-operator/";
  chart = "sops-secrets-operator";
  version = "0.28.0";
  sha256 = "sha256-bzTN/D3O3PoaQcyPX8KnIsnQP3HjhA+eZWqHnt+HxSo=";
  helmTestArgs = [
    "--kube-version"
    "1.36.0"
  ];
}
