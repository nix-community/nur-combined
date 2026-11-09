{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  aiocache,
  aiohttp,
  pkce,
  python-dateutil,
  pytz,
}:

buildPythonPackage rec {
  pname = "hydro-quebec-api-wrapper";
  version = "4.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hydroqc";
    repo = "hydroqc";
    tag = "v${version}";
    hash = "sha256-oiF6oE6voT1J0SpOWZxnZltABAYWnkB/h0wfk9St3/Y=";
  };

  # Version comes from setuptools_scm, which cannot see git metadata in the archive.
  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  build-system = [
    setuptools
    setuptools-scm
  ];

  # pyproject.toml pins exact setuptools/setuptools-scm/wheel releases.
  pypaBuildFlags = [ "--skip-dependency-check" ];

  dependencies = [
    aiocache
    aiohttp
    pkce
    python-dateutil
    pytz
  ];

  pythonImportsCheck = [ "hydroqc" ];

  meta = {
    description = "Python wrapper for the Hydro-Québec API";
    homepage = "https://github.com/hydroqc/hydroqc";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ mrene ];
  };
}
