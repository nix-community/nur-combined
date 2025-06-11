{
  lib,
  buildPythonPackage,
  fetchPypi,
  srtp,
  openssl,
  cffi,
  setuptools,
  wheel,
  coverage,
}:

buildPythonPackage rec {
  pname = "pylibsrtp";
  version = "0.12.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9cPA+2lU57t03H5jmDUnQMpnMn5nWaGZ/oUtvHuEuKw=";
  };

  buildInputs = [
    srtp
    openssl
  ];

  build-system = [
    cffi
    setuptools
    wheel
  ];

  dependencies = [
    cffi
  ];

  optional-dependencies = {
    dev = [
      coverage
    ];
  };

  pythonImportsCheck = [
    "pylibsrtp"
  ];

  meta = {
    description = "Python wrapper around the libsrtp library";
    homepage = "https://pypi.org/project/pylibsrtp";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
