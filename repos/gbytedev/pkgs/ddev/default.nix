{ lib, fetchFromGitHub, buildGoModule, docker, docker-compose }:

buildGoModule rec {
  pname = "ddev";
  version = "1.21.6";
  src = fetchFromGitHub {
    owner = "ddev";
    repo = "ddev";
    rev = "v${version}";
    sha256 = "sha256-Wjg0Yxo/ulY6R6hhUMFvNZUSwpXENmAHU7GPbgdw7tw=";
  };

  vendorSha256 = null;
  doCheck = false;

  meta = with lib; {
    description = "Docker-based local PHP+Node.js web development environments.";
    homepage = "https://github.com/ddev/ddev";
    license = licenses.asl20;
  };
}
