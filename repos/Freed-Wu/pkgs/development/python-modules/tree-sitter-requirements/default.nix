{
  mySources,
  python3,
  lib,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.tree-sitter-requirements) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.10";
  propagatedBuildInputs = [
    tree-sitter
  ];
  nativeBuildInputs = [
    setuptools
  ];
  pythonImportsCheck = [
    "tree_sitter_requirements"
  ];

  meta = with lib; {
    homepage = "https://github.com/tree-sitter-grammars/tree-sitter-requirements";
    description = "requirements.txt grammar for tree-sitter";
    license = licenses.mit;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
