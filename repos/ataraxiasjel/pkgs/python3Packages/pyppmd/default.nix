{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  setuptools,
  setuptools-scm,
  pytestCheckHook,
  hypothesis,
  py-cpuinfo,
  pytest-benchmark,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "pyppmd";
  version = "1.1.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HTjOLkt+uEtTvIpSOAuU9mumw5MouIALMMK1vzFpOXM=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    py-cpuinfo
    pytest-benchmark
  ];

  disabledTestPaths = [
    # disable benchmark
    "tests/test_benchmark.py"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    homepage = "https://codeberg.org/miurahr/pyppmd";
    description = "PPMd compression/decompression library";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
