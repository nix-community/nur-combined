{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, arrow
, nest-asyncio
, qiskit-terra
, requests
, requests_ntlm
, websockets
  # Visualization inputs
, withVisualization ? true
, ipython
, ipyvuetify
, ipywidgets
, matplotlib
, plotly
, pyperclip
, seaborn
  # check inputs
, pytestCheckHook
, nbconvert
, nbformat
, pproxy
, vcrpy
}:

let
  visualizationPackages = [
    ipython
    ipyvuetify
    ipywidgets
    matplotlib
    plotly
    pyperclip
    seaborn
  ];
in
buildPythonPackage rec {
  pname = "qiskit-ibmq-provider";
  version = "0.11.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = pname;
    rev = version;
    sha256 = "1pz3vs63v288kxz2qfm9dwhplk0d5x7x8nd7ynbj4n8ycbm0ahks";
  };

  propagatedBuildInputs = [
    arrow
    nest-asyncio
    qiskit-terra
    requests
    requests_ntlm
    websockets
  ] ++ lib.optionals withVisualization visualizationPackages;

  # Most tests require credentials to run on IBMQ
  checkInputs = [
    pytestCheckHook
    nbconvert
    nbformat
    pproxy
    vcrpy
  ] ++ lib.optionals (!withVisualization) visualizationPackages;
  dontUseSetuptoolsCheck = true;

  pythonImportsCheck = [ "qiskit.providers.ibmq" ];
  # These disabled tests require internet connection, aren't skipped elsewhere
  disabledTests = [
    "test_old_api_url"
    "test_non_auth_url"
    "test_non_auth_url_with_hub"

    # slow tests
    "test_websocket_retry_failure"
    "test_invalid_url"
  ];
  # Ensure run from source dir, not all versions of pytestcheckhook run from proper dir
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  # Skip tests that rely on internet access (mostly to IBM Quantum Experience cloud).
  # Options defined in qiskit.terra.test.testing_options.py::get_test_options
  QISKIT_TESTS = "skip_online";

  meta = with lib; {
    description = "Qiskit provider for accessing the quantum devices and simulators at IBMQ";
    homepage = "https://github.com/Qiskit/qiskit-ibmq-provider";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
