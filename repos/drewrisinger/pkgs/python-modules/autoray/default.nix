{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, numpy
, opt-einsum
  # Check Inputs
, pytestCheckHook
, matplotlib
, networkx
, pytestcov
}:

buildPythonPackage rec {
  pname = "autoray";
  version = "0.3.1";

  disabled = pythonOlder "3.5";

  src = fetchFromGitHub {
    owner = "jcmgray";
    repo = pname;
    rev = version;
    sha256 = "sha256-DSQCm9Pxlz+SNOVArQF6r08n2/8CH3sknsgEkmKu9Gs=";
  };

  propagatedBuildInputs = [
    numpy
    opt-einsum
  ];

  checkInputs = [
    pytestCheckHook
    matplotlib
    networkx
    pytestcov
  ];

  meta = with lib; {
    description = "Write numeric code that automatically works with any numpy-ish libraries";
    homepage = "https://github.com/jcmgray/autoray";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
