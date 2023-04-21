{ python3Packages, fetchFromGitHub, parallel-ssh, iotlabcli }:

python3Packages.buildPythonPackage rec {
  pname = "iotlabsshcli";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "GuilloteauQ";
    repo = "ssh-cli-tools";
    rev = "bfe257be31941f906539680d3a220c682b9ee5e6";
    sha256 = "sha256-b29z/amJGP/36YKIaZlu2Tdo7oJXSqRT/z3cLIi5TtI=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    python3Packages.scp
    python3Packages.psutil
    python3Packages.gevent
    parallel-ssh
    iotlabcli
  ];
}
