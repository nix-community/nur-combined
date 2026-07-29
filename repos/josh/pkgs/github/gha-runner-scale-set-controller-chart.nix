{ lib, nur }:
nur.repos.josh.fetchhelm {
  url = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller";
  chart = "gha-runner-scale-set-controller";
  version = "0.14.2";
  hash = "sha256-qUN0dZJTp/eBV9lO8g2p1RhymE4dVpMVSQcpGfOK6y4=";

  meta = {
    description = "A Helm chart for install actions-runner-controller CRD";
    homepage = "https://github.com/actions/actions-runner-controller";
    license = lib.licenses.asl20;
  };
}
