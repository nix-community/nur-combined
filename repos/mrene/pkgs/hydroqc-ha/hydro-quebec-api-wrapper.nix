{
  lib,
  buildPythonPackage,
  fetchFromGitLab,
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
  version = "4.2.6";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "hydroqc";
    repo = "hydroqc";
    tag = version;
    hash = "sha256-UPaRi3wyQRLN18SVkxueij9qsBeNyfmFMEJ2JQGLocg=";
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
    homepage = "https://gitlab.com/hydroqc/hydroqc";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ mrene ];
  };
}
