{ python3Packages, fetchFromGitLab }:

python3Packages.buildPythonPackage rec {
  pname = "enoslib-ansible";
  version = "10.1.0.0";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "discovery";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-v3RR7fC1yiGzU4aSoC/45wbx/Bd0Iy8Mpm/sx1uoSm8=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    python3Packages.ansible-core
  ];
}
