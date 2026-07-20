{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage {
  inherit (mySources.lsp-tree-sitter) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.10";
  propagatedBuildInputs = [
    jq
    jsonschema
    pygls
    tree-sitter
  ];
  nativeBuildInputs = [
    uv-build
  ];
  pythonImportsCheck = [
    "lsp_tree_sitter"
  ];

  meta = with lib; {
    homepage = "https://lsp-tree-sitter.readthedocs.io";
    description = "a library to create language servers";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
