{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, numpy
, qiskit-terra
, scikitlearn
, scipy
  # Check Inputs
, pytestCheckHook
, ddt
, pyfakefs
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-ignis";
  version = "0.7.1";

  disabled = pythonOlder "3.6";

  # Pypi's tarball doesn't contain tests
  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-ignis";
    rev = version;
    sha256 = "sha256-WyLNtZhtuGzqCJdOBvtBjZZiGFQihpeSjJQtP7lI248=";
  };

  propagatedBuildInputs = [
    numpy
    qiskit-terra
    scikitlearn
    scipy
  ];

  # Tests
  pythonImportsCheck = [ "qiskit.ignis" ];
  preCheck = ''
    export HOME=$TMPDIR
    pushd $TMP/$sourceRoot
  '';
  postCheck = "popd";
  checkInputs = [
    pytestCheckHook
    ddt
    pyfakefs
    qiskit-aer
  ];
  pytestFlagsArray = [ "--durations=10" ];
  disabledTests = [
    "test_tensored_meas_cal_on_circuit" # Flaky test, occasionally returns result outside bounds
    "test_qv_fitter"  # execution hangs, ran for several minutes

    # Tests failing on GitHub Actions CI
    "test_matrices_18"
    "test_bell_2_qubits"
    "test_trace_constraint"
    "TestStateTomographyCVX"
  ] ++ [
    # Slow tests
    "test_graph_construction"
  ];

  meta = with lib; {
    description = "Qiskit tools for quantum hardware verification, noise characterization, and error correction";
    homepage = "https://qiskit.org/ignis";
    downloadPage = "https://github.com/QISKit/qiskit-ignis/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
