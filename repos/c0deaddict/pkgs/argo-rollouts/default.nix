{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "argo-rollouts";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "argoproj";
    repo = "argo-rollouts";
    rev = "v${version}";
    sha256 = "1cy1m72m4ix8xcsgad5m0x07zgv95ybygkb3g1b2kqb842axjza4";
  };

  vendorSha256 = "1kwxpqy193wsimn90xlnzhs18bc9hb8sybd8fznkgb0ld1ifpzbg";

  # --- FAIL: TestGetBlueGreenRollout (0.00s)
  # panic: open github.com/argoproj/argo-rollouts/pkg/kubectl-argo-rollouts/info/testdata/blue-green: no such file or directory [recovered]
  doCheck = false;

  meta = with lib; {
    description = "Progressive Delivery for Kubernetes";
    homepage = "https://github.com/argoproj/argo-rollouts";
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
