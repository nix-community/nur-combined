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
, ddt
, pytestCheckHook
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-ignis";
  version = "0.3.3";

  disabled = pythonOlder "3.6";

  # Pypi's tarball doesn't contain tests
  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-ignis";
    rev = version;
    sha256 = "0sy9qpw0jqirsk9y61j5kr18jrw1wa812n7y98fjj6w668rrv560";
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
    qiskit-aer
  ];
  disabledTests = [
    "test_tensored_meas_cal_on_circuit" # Flaky test, occasionally returns result outside bounds
  ];
  pytestFlagsArray = [
    # Disabled b/c taking too many log lines in Travis
    "--disable-warnings"
  ];

  meta = with lib; {
    description = "Qiskit tools for quantum hardware verification, noise characterization, and error correction";
    homepage = "https://qiskit.org/ignis";
    downloadPage = "https://github.com/QISKit/qiskit-ignis/releases";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
