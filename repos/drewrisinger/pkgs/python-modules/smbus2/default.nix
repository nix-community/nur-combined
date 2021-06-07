{ buildPythonPackage
, lib
, fetchFromGitHub
, nose
}:

buildPythonPackage rec {
  pname = "smbus2";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "kplindegaard";
    repo = pname;
    rev = version;
    sha256 = "sha256-urz79x6xJNkx2SKT7QN7xQ0auG0Dv8RyHB5l+NfR+HU=";
  };

  propagatedBuildInputs = [ ];

  checkInputs = [ nose ];
  pythonImportsCheck = [ "smbus2" ];
  checkPhase = "nosetests";

  meta = with lib; {
    description = "Yet another python color library";
    homepage = "https://smbus2.readthedocs.io/en/latest/";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
