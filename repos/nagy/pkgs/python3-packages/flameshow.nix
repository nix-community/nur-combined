{
  lib,
  fetchPypi,
  buildPythonApplication,
  iteround,
  poetry-core,
  click,
  typing-extensions,
  textual,
  protobuf5,
  versionCheckHook,
}:

buildPythonApplication rec {
  pname = "flameshow";
  version = "1.1.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aJqrZeWMIymC8iWBMdL6DJpTY8U8sOaZDWZu8H7NTh0=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    click
    typing-extensions
    textual
    protobuf5
    iteround
  ];

  pythonRelaxDeps = [
    "protobuf"
    "iteround"
    "textual"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  pythonImportsCheck = [ "flameshow" ];

  meta = {
    description = "A terminal Flamegraph viewer";
    homepage = "https://github.com/laixintao/flameshow";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "flameshow";
  };
}
