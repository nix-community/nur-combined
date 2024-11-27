{
  mySources,
  python3,
  lib,
  lsp-tree-sitter,
  tree-sitter-muttrc,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.mutt-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.10";
  propagatedBuildInputs = [
    lsp-tree-sitter
    tree-sitter-muttrc
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "mutt_language_server"
  ];

  meta = with lib; {
    homepage = "https://mutt-language-server.readthedocs.io";
    description = "mutt/neomutt's language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
