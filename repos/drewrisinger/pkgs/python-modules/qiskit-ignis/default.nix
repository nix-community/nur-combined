{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, python
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
  version = "0.5.1";

  disabled = pythonOlder "3.6";

  # Pypi's tarball doesn't contain tests
  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-ignis";
    rev = version;
    sha256 = "17kplmi17axcbbgw35dzfr3d5bzfymxfni9sf6v14223c5674p4y";
  };

  propagatedBuildInputs = [
    numpy
    qiskit-terra
    scikitlearn
    scipy
  ];
  postInstall = "rm -rf $out/${python.sitePackages}/docs";

  # Tests
  pythonImportsCheck = [ "qiskit.ignis" ];
  dontUseSetuptoolsCheck = true;
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
  disabledTests = [
    "test_tensored_meas_cal_on_circuit" # Flaky test, occasionally returns result outside bounds
    "test_qv_fitter"  # execution hangs, ran for several minutes
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
