{ python3Packages
, generated
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  inherit (generated) pname src;

  version = "0.2.1"; # Must be a valid PEP 440 version, for SETUPTOOLS_SCM_PRETEND_VERSION
  format = "pyproject";

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

  # nativeCheckInputs = [ pytestCheckHook ];

  # pythonImportsCheck = [ "beetsplug.summarize" ];

  meta = {
    description = "Summarize beet library statistics";
    homepage = "https://github.com/steven-murray/beet-summarize";
    license = lib.licenses.lgpl3Only;
  };
}
