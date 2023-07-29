{ lib, fetchFromGitHub, buildGoModule, docker, docker-compose }:

buildGoModule rec {
  pname = "ddev";
  version = "1.22.0";
  src = fetchFromGitHub {
    owner = "ddev";
    repo = "ddev";
    rev = "v${version}";
    sha256 = "0clk7jqch2ryq2ma4cybzzxg3dxszcc2r45sqcb54bf46g8iw9x5";
  };

  vendorSha256 = null;
  doCheck = false;

  meta = with lib; {
    description = "Docker-based local PHP+Node.js web development environments.";
    homepage = "https://github.com/ddev/ddev";
    license = licenses.asl20;
  };
}
