{ nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set";
  chart = "gha-runner-scale-set";
  version = "0.14.2";
  sha256 = "sha256-2SwbbcpXShtmOGtkRpLCCSQEI378TvBH7ZDYnKyFhWs=";
  helmTestValues = {
    controllerServiceAccount.name = "test";
    controllerServiceAccount.namespace = "default";
    githubConfigUrl = "https://github.com/test/test";
    githubConfigSecret.github_token = "test";
  };
}
