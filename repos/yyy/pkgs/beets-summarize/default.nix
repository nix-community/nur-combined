{ python3Packages
, fetchFromGitHub
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pname = "beet-summarize";
  version = "unstable-2023-09-26";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "steven-murray";
    repo = "beet-summarize";
    rev = "0bee03ca57f664c828780766cac219bbd002ccb8";
    hash = "sha256-GnfEVJPx0kLrepYCKld0IBLjj3sziT6WU8ecYtLLSw0=";
  };

  nativeBuildInputs = [
    beets
    setuptools
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
