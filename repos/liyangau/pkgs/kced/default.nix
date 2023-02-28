{ buildGoModule, lib, fetchFromGitHub }:

buildGoModule rec {
  pname = "kced";
  version = "0.1.6";
  sha = "b951c9b";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = pname ;
    rev = "v${version}";
    sha256 = "sha256-5c6B2nPTWPUE4SCEc0jCKCWLG2HEAa5SnkFh0W2L5JY=";
  };

  CGO_ENABLED = 0;

  ldflags = [
    "-s -w -X github.com/kong/kced/cmd.VERSION=${version}"
    "-X github.com/kong/kced/cmd.COMMIT=${sha}"
  ];
  vendorSha256 = "sha256-75Pop8MxAV3Y3OVpR6fNf/7f2WHcIfir9aihZ2lRw3o=";

  meta = with lib; {
    description = "A prototyping space for APIOps v2 for Kong.";
    homepage    = "https://github.com/Kong/kced";
    license     = licenses.asl20;
  };
}
