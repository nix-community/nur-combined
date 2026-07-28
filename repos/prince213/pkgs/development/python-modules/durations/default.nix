{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # nativeCheckInputs
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "durations";
  version = "0.3.3";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "oleiade";
    repo = "durations";
    tag = finalAttrs.version;
    hash = "sha256-oXuMHHnl/uUzZVqln97poIpZce5aMwEyatDLhpwl90A=";
  };

  build-system = [ setuptools ];

  pythonImportsCheck = [ "durations" ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    description = "Python durations parsing library";
    homepage = "https://github.com/oleiade/durations";
    downloadPage = "https://github.com/oleiade/durations/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
