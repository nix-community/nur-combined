{ buildPythonPackage
, lib
, fetchFromGitHub
, nose
}:

buildPythonPackage rec {
  pname = "smbus2";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "kplindegaard";
    repo = pname;
    rev = version;
    sha256 = "1dfns2dmv81g87yp2l5qm9a9v8ayi9qfwzzw5i216kg6l3zba2fq";
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
