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

buildPythonPackage (finalAttrs: {
  pname = "aiortc";
  version = "1.17.0";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-acFL4WmYObNquNiRCxVc2ViC8x6UtS7fspPNgnFk31Q=";
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
})
