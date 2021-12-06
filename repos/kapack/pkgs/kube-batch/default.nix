{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  pname = "kube-batch";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kube-batch";
    rev = "v${version}";
    sha256 = "1byxnlgl1dysgcivl0b45n9dvpg43szw10hy34mhamjn1zhxs2w3";
  };

  goPackagePath = "github.com/kubernetes-sigs/kube-batch";

  subPackages = [ "cmd/kube-batch" ];

  ldflags = ''
    -X github.com/kubernetes-sigs/kube-batch/pkg/version.Version=${version}
  '';

  meta = with lib; {
    homepage = "https://github.com/kubernetes-sigs/kube-batch";
    description = "The Kubernetes Native Serverless Framework";
    license = licenses.asl20;
    maintainers = with maintainers; [];
    platforms = platforms.unix;
  };
}
