{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-whoami";
  version = "0.0.44";

  src = fetchFromGitHub {
    owner = "rajatjindal";
    repo = "kubectl-whoami";
    rev = "v${version}";
    sha256 = "sha256-HYHQIkmKlwfk/TylBiLY4X+317tqzeC48+e/QOtRBxo=";
  };

  vendorSha256 = "sha256-tezDL7YZKGpYzXShPylsUXDiLWos3C2Wt6jJCd61FYo=";

  doCheck = false;
  subPackages = [ "." ];

  meta = with lib; {
    description = "A kubectl plugin that gets the subject name using the effective kubeconfig";
    homepage = "https://github.com/rajatjindal/kubectl-whoami/";
    license = licenses.asl20;
    maintainers = with maintainers; [ tboerger ];
  };
}
