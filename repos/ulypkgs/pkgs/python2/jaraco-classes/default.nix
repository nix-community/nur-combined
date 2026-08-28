{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  isPy27,
  setuptools-scm,
  more-itertools,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "jaraco.classes";
  version = "3.1.1";
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.classes";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+Q5QoOTXRGDQ+LBjGqo8g6uIQM0NPK9sLGa9FLtm+XM=";
  };

  pythonNamespaces = [ "jaraco" ];

  SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [ more-itertools ];

  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Utility functions for Python class constructs";
    homepage = "https://github.com/jaraco/jaraco.classes";
    license = licenses.mit;
  };
})
