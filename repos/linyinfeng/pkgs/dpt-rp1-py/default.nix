{ lib, python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "dpt-rp1-py";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "janten";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-syWOAjOFUSn0d6CfSR/9uYZdEwzV1wZ0R6lbN4t188k=";
  };

  doCheck = false;

  propagatedBuildInputs = with python3Packages; [
    setuptools
    httpsig
    requests
    pbkdf2
    urllib3
    pyyaml
    anytree
    fusepy
    zeroconf
    tqdm
  ];

  meta = with lib; {
    homepage = "https://github.com/janten/dpt-rp1-py";
    description = "Python script to manage Sony DPT-RP1 without Digital Paper App";
    license = licenses.mit;
  };
}
