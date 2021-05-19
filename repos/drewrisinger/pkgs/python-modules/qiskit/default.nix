{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, qiskit-aer
, qiskit-aqua
, qiskit-ibmq-provider
, qiskit-ignis
, qiskit-terra
  # Optional inputs
, withOptionalPackages ? true
, qiskit-finance
, qiskit-machine-learning
, qiskit-nature
, qiskit-optimization
  # Check Inputs
, pytestCheckHook
}:

let
  optionalQiskitPackages = [
    qiskit-finance
    qiskit-machine-learning
    qiskit-nature
    qiskit-optimization
  ];
in
buildPythonPackage rec {
  pname = "qiskit";
  # NOTE: This version denotes a specific set of subpackages. See https://qiskit.org/documentation/release_notes.html#version-history
  version = "0.26.2";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit";
    rev = version;
    sha256 = "072sl6q9aqica28zvjh2rvnajjglq245g5lvwsny1zny5qlqm1a1";
  };

  propagatedBuildInputs = [
    qiskit-aer
    qiskit-aqua
    qiskit-ibmq-provider
    qiskit-ignis
    qiskit-terra
  ] ++ lib.optionals withOptionalPackages optionalQiskitPackages;

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [
    "qiskit"
    "qiskit.aqua"
    "qiskit.circuit"
    "qiskit.ignis"
    "qiskit.providers.aer"
    "qiskit.providers.ibmq"
  ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  meta = with lib; {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/QISKit/qiskit/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger pandaman ];
  };
}
