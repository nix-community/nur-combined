{ sources, lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  inherit (sources.dpt-rp1-py) pname version src;

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
    # TODO https://github.com/pyca/pyopenssl/issues/873
    broken = python3Packages.pyopenssl.meta.broken;
  };
}
