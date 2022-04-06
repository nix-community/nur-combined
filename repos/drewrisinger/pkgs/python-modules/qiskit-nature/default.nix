{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, h5py
, numpy
, psutil
, qiskit-terra
, retworkx
, scikitlearn
, scipy
, withPyscf ? false
, pyscf
  # Check Inputs
, pytestCheckHook
, ddt
, pylatexenc
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-nature";
  version = "0.3.2";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "sha256-BXUVRZ8X3OJiRexNXZsnvp+Yh8ARNYohYH49/IYFYM0=";
  };

  propagatedBuildInputs = [
    h5py
    numpy
    psutil
    qiskit-terra
    retworkx
    scikitlearn
    scipy
  ] ++ lib.optional withPyscf pyscf;

  checkInputs = [
    pytestCheckHook
    ddt
    pylatexenc
    qiskit-aer
  ];

  pythonImportsCheck = [ "qiskit_nature" ];

  pytestFlagsArray = [
    "--durations=10"
  ] ++ lib.optionals (!withPyscf) [
    "--ignore=test/algorithms/excited_state_solvers/test_excited_states_eigensolver.py"
  ];

  disabledTests = [
    # Slow tests > 10s
    "test_hf_bitstring_mapped"
    # Fails on GitHub Actions, small math error < 0.05 (< 9e-6 %)
    "test_vqe_uvccsd_factory"
  ] ++ lib.optionals (scipy.version == "1.6.1") [
    "test_to_matrix"  # fails due to https://github.com/scipy/scipy/issues/13585, fixed in 1.6.2
  ] ++ lib.optionals (!withPyscf) [
    "test_h2_bopes_sampler"
    "test_potential_interface"
  ] ++ lib.optionals (lib.versionAtLeast qiskit-terra.version "0.19.0") [
    # fail with qiskit-terra >= 0.19.0, apparently.
    "test_two_qubit_reduction"
  ];

  meta = with lib; {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/QISKit/qiskit-nature/releases";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
