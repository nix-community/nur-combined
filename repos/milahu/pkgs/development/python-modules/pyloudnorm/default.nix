{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  numpy,
  scipy,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyloudnorm";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "csteinmetz1";
    repo = "pyloudnorm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-47CU/veoOQYv5G1QBm3F+j7ltmVvcWSY4hQWtaC6WEI=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    numpy
    scipy
  ];

  pythonImportsCheck = [
    "pyloudnorm"
  ];

  meta = {
    description = "Flexible audio loudness meter in Python with implementation of ITU-R BS.1770-4 loudness algorithm";
    homepage = "https://github.com/csteinmetz1/pyloudnorm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
