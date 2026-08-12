{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, numpy
, scipy
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "csaps";
  version = "1.1.0";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "espdev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4k/WsyQhuXSmaTrGSOiKumAKlIdB5Nb6WkLcPW8AhcY=";
  };

  propagatedBuildInputs = [ numpy scipy ];

  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Cubic spline approximation (smoothing)";
    maintainers = with maintainers; [ drewrisinger ];
    license = licenses.mit;
    homepage = "https://csaps.readthedocs.io/en/latest/";
  };
}
