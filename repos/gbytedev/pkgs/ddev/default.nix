{ lib, fetchFromGitHub, buildGoModule, docker }:

buildGoModule rec {
  pname = "ddev";
  version = "1.22.1";
  src = fetchFromGitHub {
    owner = "ddev";
    repo = "ddev";
    rev = "v${version}";
    sha256 = "0y86d3hxsl74nq6lj24cvxxi70yzrhalimgyx2c8i7mvrnkxvq6y";
  };

  vendorSha256 = null;
  doCheck = false;

  meta = with lib; {
    description = "Docker-based local PHP+Node.js web development environments.";
    homepage = "https://github.com/ddev/ddev";
    license = licenses.asl20;
  };
}
