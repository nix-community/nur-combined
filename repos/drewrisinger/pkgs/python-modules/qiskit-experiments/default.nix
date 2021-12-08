{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, matplotlib
, numpy
, qiskit-terra
, qiskit-ibmq-provider
, scipy
  # Check Inputs
, pytestCheckHook
, ddt
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-experiments";
  version = "0.1.0";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "sha256-tXzapOn8ej25nrY+O+E7FvcwHCy2sfvbMu8v6n8H6H4=";
  };

  propagatedBuildInputs = [
    matplotlib
    numpy
    qiskit-terra
    qiskit-ibmq-provider
    scipy
  ];

  checkInputs = [
    pytestCheckHook
    ddt
    qiskit-aer
  ];

  pythonImportsCheck = [ "qiskit_experiments" ];

  pytestFlagsArray = [
  ];

  disabledTests = [
  ];

  meta = with lib; {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/QISKit/qiskit-optimization/releases";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
