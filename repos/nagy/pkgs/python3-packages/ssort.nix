{
  lib,
  pathspec,
  setuptools,
  fetchPypi,
  buildPythonApplication,
  versionCheckHook,
}:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.17.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-rPs4QJR2Ugw+JVQcKC9875IBeQDYWfaxK+pI2kM0sZQ=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    pathspec
  ];

  pythonImportsCheck = [ "ssort" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Tool for sorting top level statements in python files";
    homepage = "https://github.com/bwhmather/ssort";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ssort";
  };
}
