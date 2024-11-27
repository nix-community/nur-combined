{
  mySources,
  python3,
  lib,
  lsp-tree-sitter,
  tree-sitter-zathurarc,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.zathura-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    lsp-tree-sitter
    tree-sitter-zathurarc
    webcolors
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "zathura_language_server"
  ];

  meta = with lib; {
    homepage = "https://zathura-language-server.readthedocs.io";
    description = "zathura's language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
