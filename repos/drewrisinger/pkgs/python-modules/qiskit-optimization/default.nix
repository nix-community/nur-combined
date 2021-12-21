{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, decorator
, docplex
, networkx
, numpy
, qiskit-terra
, scipy
  # Check Inputs
, pytestCheckHook
, ddt
, pylatexenc
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-optimization";
  version = "0.3.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "sha256-gNW8zb5URXqKIvd4Fh9+XDzACi6/34G5km4cGUQFGqM=";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace "networkx>=2.2,<2.6" "networkx"
  '';

  propagatedBuildInputs = [
    docplex
    decorator
    networkx
    numpy
    qiskit-terra
    scipy
  ];

  checkInputs = [
    pytestCheckHook
    ddt
    pylatexenc
    qiskit-aer
  ];

  pythonImportsCheck = [ "qiskit_optimization" ];
  pytestFlagsArray = [ "--durations=10" ];

  disabledTests = [
    "test_samples_qaoa_2_qasm"  # fails with qiskit-terra == 0.19.0 for some reason
  ];

  meta = with lib; {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/QISKit/qiskit-optimization/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
