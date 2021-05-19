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
}:

buildPythonPackage rec {
  pname = "qiskit-nature";
  version = "0.1.3";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "1mj3pgl4lfnzbhd9k1nkqscmrqhd5jmxm8318bjbg8yagvzi5mz7";
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
  ];
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [ "qiskit_nature" ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  pytestFlagsArray = lib.optionals (!withPyscf) [
    "--ignore=test/algorithms/excited_state_solvers/test_excited_states_eigensolver.py"
  ];

  disabledTests = [
    # Fails on GitHub Actions, small math error < 0.05 (< 9e-6 %)
    "test_vqe_uvccsd_factory"
  ] ++ lib.optionals (!withPyscf) [
    "test_h2_bopes_sampler"
    "test_potential_interface"
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
