{ lib
, pythonOlder
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
  version = "0.1.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "0x9hvvjlpf30993y7wlyqgfh8paiskiw0qd24h9xi7ip65b1qvrv";
  };

  patches = [
    (fetchpatch {
      name = "qiskit-machine-learning-pr-55-torch-optional-tests.patch";
      url = "https://github.com/Qiskit/qiskit-machine-learning/commit/89bc4308bab42637b91aca8f353ac219d99f93d0.patch";
      sha256 = "1lf6s65b3i1q2s5dfv4k9l1f0njm93b7biz4kr8ggwwmrqy7pmli";
    })
  ];

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
  ];
  disabledTests = [
    # Slow tests >10 s
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
