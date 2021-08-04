{ lib
, pythonOlder
, pythonAtLeast
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
  # Python Inputs
, fastdtw
, numpy
, psutil
, qiskit-terra
, scikitlearn
, sparse
  # Optional inputs
  # Fails some tests with older version of torch on nixos-20.03, easier just to disable
, withTorch ? (lib.versionAtLeast lib.trivial.version "20.09")
, pytorch
  # Check Inputs
, pytestCheckHook
, ddt
, pytest-timeout
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-machine-learning";
  version = "0.2.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "sha256-AwEKJOwDcTEA8gxgv7abx6qDPMPpb+wcaygK8tjtNGI=";
  };

  propagatedBuildInputs = [
    fastdtw
    numpy
    psutil
    qiskit-terra
    scikitlearn
    sparse
  ] ++ lib.optional withTorch pytorch;

  checkInputs = [
    pytestCheckHook
    pytest-timeout
    ddt
    qiskit-aer
  ];
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [ "qiskit_machine_learning" ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  pytestFlagsArray = [
    "--durations=10"
    "--showlocals"
    "-vv"
  ] ++ lib.optionals (lib.versionAtLeast lib.version "20.09") [
    "--ignore=test/connectors/test_torch_connector.py"  # TODO: fix, get multithreading errors with python3.9, segfaults
  ];
  disabledTests = [
    # Slow tests >10 s
    "test_readme_sample"
    "test_vqr_8"
    "test_vqr_7"
    "test_qgan_training_cg"
    "test_vqc_4"
    "test_classifier_with_circuit_qnn_and_cross_entropy_4"
    "test_vqr_4"
    "test_regressor_with_opflow_qnn_4"
    "test_qgan_save_model"
    "test_qgan_training_analytic_gradients"
    "test_qgan_training_run_algo_numpy"
    "test_ad_hoc_data"
    "test_qgan_training"
  ] ++ lib.optionals (lib.versionOlder lib.version "20.09") [
    # seem to fail on nixpkgs-20.03. maybe older scipy version??
    "bfgs"
    "test_vqr_09"
    "test_vqr_10"
    "test_vqr_11"
    "test_vqr_12"
    "test_vqc_5"
    "test_vqc_6"
    "qnn_and_cross_entropy_5"
    "qnn_and_cross_entropy_6"
    "test_classifier_with_opflow_qnn_10"
    "test_classifier_with_opflow_qnn_9"
    "test_classifier_with_opflow_qnn_11"
    "test_classifier_with_opflow_qnn_12"
    "test_regressor_with_opflow_qnn_5"
    "test_regressor_with_opflow_qnn_6"
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
