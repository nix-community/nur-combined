{
  lib,
  pkgs,
  fetchPypi,
  buildPythonPackage,
  poetry-core,
  iteround,
  rich,
  textual,
  typing-extensions,
  protobuf5,
}:

buildPythonPackage (finalAttrs: {
  pname = "flamegraph-textual";
  version = "0.1.2";
  pyproject = true;

  src = fetchPypi {
    pname = "flamegraph_textual";
    inherit (finalAttrs) version;
    hash = "sha256-DZ5IkSDjFEvgCnp+7oWQjEJWphOo3WCZVS18Eyw9/iI=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    iteround
    rich
    textual
    typing-extensions
    protobuf5
  ];

  # nixpkgs carries newer textual/rich, older protobuf, and iteround 1.0.4.
  pythonRelaxDeps = [
    "iteround"
    "protobuf"
    "rich"
    "textual"
  ];

  pythonImportsCheck = [ "flamegraph_textual" ];

  passthru.updateScript = pkgs.nix-update-script { };

  meta = {
    description = "Flamegraph visualization for Textual";
    homepage = "https://github.com/laixintao/flamegraph-textual";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
