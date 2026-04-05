{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  pytest,
}:

buildPythonPackage rec {
  pname = "pytoml";
  version = "0.1.20";

  src = fetchFromGitHub {
    owner = "avakar";
    repo = "pytoml";
    tag = "v${version}";
    fetchSubmodules = true; # ensure test submodule is available
    hash = "sha256-vxpC/596t3nDQzxLDRKLzmylyfgbjrq0A99A+AnBEgo=";
  };

  checkInputs = [ pytest ];

  checkPhase = ''
    ${python.interpreter} test/test.py
    pytest test
  '';

  doCheck = false;

  meta = with lib; {
    description = "A TOML parser/writer for Python";
    homepage = "https://github.com/avakar/pytoml";
    license = licenses.mit;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
