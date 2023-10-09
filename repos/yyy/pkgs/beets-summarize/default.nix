{ python3Packages
, fetchFromGitHub
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pname = "beet-summarize";
  version = "0.2.0"; # Must be a valid PEP 440 version, for SETUPTOOLS_SCM_PRETEND_VERSION
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "steven-murray";
    repo = "beet-summarize";
    rev = "0bee03ca57f664c828780766cac219bbd002ccb8";
    hash = "sha256-GnfEVJPx0kLrepYCKld0IBLjj3sziT6WU8ecYtLLSw0=";
  };


  # LookupError: setuptools-scm was unable to detect version for xxx
  # https://github.com/steven-murray/beet-summarize/blob/main/pyproject.toml
  # https://github.com/steven-murray/beet-summarize/blob/main/beetsplug/__init__.py
  # https://stackoverflow.com/questions/70272023/using-pyproject-toml-with-flexible-version-from-datetime
  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  nativeBuildInputs = [
    beets
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "beetsplug.summarize" ];

  meta = {
    description = "Summarize beet library statistics";
    homepage = "https://github.com/steven-murray/beet-summarize";
    license = lib.licenses.lgpl3Only;
  };
}
