{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
  setuptools,
  aiohttp,
  async-lru,
  cachetools,
  pydantic,
  requests,
  tenacity,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "buildgrid-metering-client";
  version = "0.0.4";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "BuildGrid";
    repo = "buildgrid-metering-client";
    rev = "3d2a1b7481a9a3c24c3b103f257152ad49c4e93c";
    hash = "sha256-BTkFBsbrUrXzKG75TgaAp9n1i1JnF+mH+Os6lqvPODY=";
  };

  build-system = [
    setuptools
  ];
  dependencies = [
    aiohttp
    async-lru
    cachetools
    pydantic
    requests
    tenacity
  ];

  passthru.updateScript = null;

  meta = {
    description = "Asyncio Python client of buildgrid-metering service";
    homepage = "https://gitlab.com/BuildGrid/buildgrid-metering-client";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    broken = lib.strings.versionAtLeast python.version "3.15";
  };
})
