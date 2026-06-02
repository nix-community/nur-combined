{ nur }:
nur.repos.josh.fetchhelm {
  url = "https://isindir.github.io/sops-secrets-operator/";
  chart = "sops-secrets-operator";
  version = "0.27.1";
  sha256 = "sha256-Sni+5iz3mRod9Us2hBgca2DK+LXYgoK96+V/DTN1nVM=";
  helmTestArgs = [
    "--kube-version"
    "1.36.0"
  ];
}
