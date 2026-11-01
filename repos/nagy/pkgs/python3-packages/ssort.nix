{
  lib,
  pkgs,
  pathspec,
  setuptools,
  fetchPypi,
  buildPythonApplication,
  versionCheckHook,
}:

buildPythonApplication rec {
  pname = "ssort";
  version = "0.19.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-G/8DakotgxvsyCK04R6ubk+L+z44buIHsIJGnTtgSmo=";
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

  passthru.updateScript = pkgs.nix-update-script { };

  meta = {
    description = "Tool for sorting top level statements in python files";
    homepage = "https://github.com/bwhmather/ssort";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ssort";
  };
}
