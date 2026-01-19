{
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchPypi,
  build,
  setuptools,
  setuptools-scm,

  brotli,
  inflate64,
  multivolumefile,
  psutil,
  pybcj,
  pycryptodomex,
  pyppmd,
  pyzstd,
  texttable,
  pytestCheckHook,
  py-cpuinfo,
  pytest-benchmark,
  pytest-httpserver,
  requests,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "py7zr";
  version = "1.1.2";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ku4hLFUW3cvrdodNw+zji0Vm/AA/UWAAMscjz+qJrFY=";
  };

  build-system = [
    build
    setuptools
    setuptools-scm
  ];

  dependencies = [
    brotli
    inflate64
    multivolumefile
    psutil
    pybcj
    pycryptodomex
    pyppmd
    pyzstd
    texttable
  ];

  nativeCheckInputs = [
    pytestCheckHook
    py-cpuinfo
    pytest-benchmark
    pytest-httpserver
    requests
  ];

  disabledTestPaths = [
    # disable benchmark
    "tests/test_benchmark.py"
    # requires download file from internet
    "tests/test_concurrent.py"
  ];

  passthru.updateScript = nix-update-script { };
  # passthru.skipBulkUpdate = true;

  meta = with lib; {
    homepage = "https://github.com/cs3org/python-cs3apis/";
    description = "Official Python CS3APIS";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
