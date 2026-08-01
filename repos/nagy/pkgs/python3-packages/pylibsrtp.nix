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
  version = "1.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-s53/B1smOo3tU3fySQxg0q9FLJ8GxNBhx6K2QGErNNQ=";
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
    homepage = "https://github.com/aiortc/pylibsrtp";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
