{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "drone-runner-ssh";
  version = "2020-10-02";

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-ssh";
    rev = "a3f489f55ca32648240dd7c637a961c3119b2516";
    sha256 = "sha256-8AgFL3rdZ08w5BRRC8CdTUgHvDuArVcHA9kueHG9Yro=";
  };

  vendorSha256 = "sha256-2rL64YQDr2NZ0Dv+T/DuEjS+XpXV2Dtma78w9n36fT4=";

  meta = with lib; {
    description = "Drone runner that executes a pipeline on a remote machine";
    homepage = "https://github.com/drone-runners/drone-runner-ssh";
    # https://polyformproject.org/licenses/small-business/1.0.0/
    license = licenses.unfree;
  };
}
