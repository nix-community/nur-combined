{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.lsp-tree-sitter) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    colorama
    jinja2
    jsonschema
    pygls
    tree-sitter
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "lsp_tree_sitter"
  ];

  meta = with lib; {
    homepage = "https://lsp-tree-sitter.readthedocs.io";
    description = "A library to create language servers";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
