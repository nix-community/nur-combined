{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  aio-krpc-server,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-btdht";
  version = "0.0.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bashkirtsevich-llc";
    repo = "aiobtdht";
    rev = "f99d881e9b992da13519721e251912c32a566cd7";
    hash = "sha256-Hv3TafpI9wzYD4c95/iXlRLbJx3TQOJRu21igutshQA=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    aio-krpc-server
  ];

  pythonImportsCheck = [
    "aiobtdht"
  ];

  meta = {
    description = "Asyncio Bittorrent DHT server";
    homepage = "https://github.com/bashkirtsevich-llc/aiobtdht";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
