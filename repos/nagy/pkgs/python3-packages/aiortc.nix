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
  version = "1.15.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7mwHV8oHDPbWvuRBk21u3iTu9RIRu/9mU0CcVA9y5iU=";
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
