{
  lib,
  pkgs,
  fetchPypi,
  buildPythonApplication,
  iteround,
  poetry-core,
  click,
  typing-extensions,
  textual,
  protobuf5,
  flamegraph-textual,
  versionCheckHook,
}:

buildPythonApplication (finalAttrs: {
  pname = "flameshow";
  version = "1.1.5";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-K3qQczjQo/inHUa5BEnYYDYzR4RC0FqAbpBXan3llzI=";
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
    flamegraph-textual
  ];

  pythonRelaxDeps = [
    "protobuf"
    "iteround"
    "textual"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = pkgs.nix-update-script { };

  pythonImportsCheck = [ "flameshow" ];

  meta = {
    description = "A terminal Flamegraph viewer";
    homepage = "https://github.com/laixintao/flameshow";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "flameshow";
  };
})
