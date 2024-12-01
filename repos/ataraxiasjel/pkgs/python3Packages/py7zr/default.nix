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
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "py7zr";
  version = "0.22.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xseupZE1NRhAA7c5OEkPmk2EGFmOUz+cqZHTuORaE54=";
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
