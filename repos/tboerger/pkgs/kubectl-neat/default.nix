{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-neat";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "itaysk";
    repo = "kubectl-neat";
    rev = "v${version}";
    sha256 = "sha256-j8v0zJDBqHzmLamIZPW9UvMe9bv/m3JUQKY+wsgMTFk=";
  };

  vendorSha256 = "sha256-vGXoYR0DT9V1BD/FN/4szOal0clsLlqReTFkAd2beMw=";

  doCheck = false;
  subPackages = [ "." ];

  meta = with lib; {
    description = "A kubectl plugin that cleans up Kubernetes yaml and json output to make it readable";
    homepage = "https://github.com/itaysk/kubectl-neat/";
    license = licenses.asl20;
    maintainers = with maintainers; [ tboerger ];
  };
}
