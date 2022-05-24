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
, uncertainties
  # Check Inputs
, pytestCheckHook
, ddt
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-experiments";
  version = "0.3.1";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "sha256-rGMVxlqwnA18Sq3O1LUZoC36oj+FnuaZLdjyTyANZh0=";
  };

  propagatedBuildInputs = [
    matplotlib
    numpy
    qiskit-terra
    qiskit-ibmq-provider
    scipy
    uncertainties
  ];

  checkInputs = [
    pytestCheckHook
    ddt
    qiskit-aer
  ];

  pythonImportsCheck = [ "qiskit_experiments" ];

  disabledTests = [
    # slow tests
    "test_integration_"
    "test_t2hahn_run_end2end"
    "test_t2hahn_parallel"
    "test_readout_angle_end2end"
    "test_rabi_end_to_end"
    "test_2q_epg"
    "test_single_qubit"
    "test_t2hahn_concat_2_experiments"
    "test_correct_1q_depolarization"
    "test_default_epg_ratio"
    "test_no_epg"
    "test_with_custom_epg_ratio"
    "test_full_qpt_random_unitary"
    "test_t2ramsey_run_end2end"
    "test_roundtrip_serializable"
    "test_end_to_end"
    "test_update"
    "test_clifford_2_qubit_generation"
    "test_ef_update"
    "test_cvxpy_gaussian_lstsq_cx"
    "test_two_qubit"
    "test_spectroscopy_end2end_kerneled"
  ];
  pytestFlagsArray = [
    "-v"
    "--durations=40"
  ];

  meta = with lib; {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/QISKit/qiskit-experiments/releases";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
