{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  name = "kube-burner";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "kube-burner";
    repo = "kube-burner";
    rev = "v${version}";
    hash = "sha256-zJkBgujJbJTD34KQ7UZPf1y04YvoOLfBnPBW8rh0CK8=";
  };

  vendorHash = "sha256-q6qq66tmVUudhmts8a5mG74mlXPcayJuov38COgu1dQ=";

  # test fail.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/kube-burner/kube-burner";
    description = "Kubernetes performance and scale test orchestration framework written in golang";
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
