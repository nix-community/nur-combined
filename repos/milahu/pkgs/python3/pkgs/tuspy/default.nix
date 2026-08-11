{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  requests,
  tinydb,
  aiohttp,
}:

buildPythonPackage rec {
  pname = "tuspy";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tus";
    repo = "tus-py-client";
    rev = "v${version}";
    hash = "sha256-rlVB511s290NV/1fDgejWjE619Md02qFPybfJ2SOYiw=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    requests
    tinydb
    aiohttp
  ];

  pythonImportsCheck = [
    "tusclient"
  ];

  meta = {
    description = "A Python client for the tus resumable upload protocol";
    homepage = "https://github.com/tus/tus-py-client";
    changelog = "https://github.com/tus/tus-py-client/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
