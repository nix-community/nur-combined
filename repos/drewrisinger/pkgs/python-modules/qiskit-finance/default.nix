{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
, fastdtw
, numpy
, pandas
, psutil
, qiskit-terra
, qiskit-optimization
, scikitlearn
, scipy
, quandl
, yfinance
  # Check Inputs
, pytestCheckHook
, ddt
, pytest-timeout
, qiskit-aer
}:

buildPythonPackage rec {
  pname = "qiskit-finance";
  version = "0.2.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "sha256-Ua+2cZniA9Wh1tr2OjGsi8iwXNg1InTjGQ9kau9UZdU=";
  };

  propagatedBuildInputs = [
    fastdtw
    numpy
    pandas
    psutil
    qiskit-terra
    qiskit-optimization
    quandl
    scikitlearn
    scipy
    yfinance
  ];

  checkInputs = [
    pytestCheckHook
    pytest-timeout
    ddt
    qiskit-aer
  ];
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [ "qiskit_finance" ];
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";
  disabledTests = [
    # Tests fail b/c require internet connection. Stalls tests if enabled.
    "test_exchangedata"
    "test_yahoo"
    "test_wikipedia"
  ];
  pytestFlagsArray = [
    "--durations=10"
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
