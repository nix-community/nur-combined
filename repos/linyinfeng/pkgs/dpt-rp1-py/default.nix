{ lib, python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "dpt-rp1-py";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "janten";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-WCu7DBboTeHR/PC0b0y/ht0b4peuUcNPyVT0VfQoiHc=";
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
