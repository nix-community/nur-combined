{
  buildPythonPackage,
  pydantic,
  pcpp,
  pyyaml,
  platformdirs,
  pydantic-settings,
  tree-sitter,
  tree-sitter-devicetree,
  pyparsing,
  poetry-core,
  pythonRelaxDepsHook,
  fetchurl,
}:
buildPythonPackage rec {
  pname = "keymap-drawer";
  version = "0.22.1";

  src = fetchurl {
    url = "https://pypi.org/packages/source/k/keymap_drawer/keymap_drawer-${version}.tar.gz";
    hash = "sha256-DPkQbw5tpEMJuVqa2IiD9W5Fn9hxQZKHygu3x7oEobo=";
  };
  pyproject = true;

  patches = [ ./tree-sitter.patch ];

  nativeBuildInputs = [
    poetry-core
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [ "tree-sitter" ];

  propagatedBuildInputs = [
    pydantic
    pcpp
    pyparsing
    pyyaml
    platformdirs
    pydantic-settings
    tree-sitter
    tree-sitter-devicetree
  ];

}
