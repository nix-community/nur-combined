{ python3Packages, fetchFromGitHub, iotlabcli }:

python3Packages.buildPythonPackage rec {
  pname = "iotlabsshcli";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "iot-lab";
    repo = "ssh-cli-tools";
    rev = version;
    sha256 = "sha256-kYCWv0J7Wp88rqxh7ZqOAypq2/JD1hLX0463aiPbdVs=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    python3Packages.scp
    python3Packages.psutil
    python3Packages.gevent
    python3Packages.parallel-ssh
    iotlabcli
  ];
  meta.broken = true;
}
