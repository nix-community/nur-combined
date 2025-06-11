{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  aioice,
  av,
  cffi,
  cryptography,
  google-crc32c,
  pyee,
  pylibsrtp,
  pyopenssl,
  aiohttp,
  coverage,
  numpy,
}:

buildPythonPackage rec {
  pname = "aiortc";
  version = "1.13.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XSCZdcItCRD7Wg8OLKqCjy2pZsU1gPfHFwrDoWqHFiA=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    aioice
    av
    cffi
    cryptography
    google-crc32c
    pyee
    pylibsrtp
    pyopenssl
  ];

  optional-dependencies = {
    dev = [
      aiohttp
      coverage
      numpy
    ];
  };

  pythonImportsCheck = [
    "aiortc"
  ];

  meta = {
    description = "An implementation of WebRTC and ORTC";
    homepage = "https://pypi.org/project/aiortc";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "aiortc";
  };
}
