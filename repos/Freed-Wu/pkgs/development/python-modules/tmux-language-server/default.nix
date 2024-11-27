{
  mySources,
  python3,
  lib,
  lsp-tree-sitter,
  tree-sitter-tmux,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.tmux-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.10";
  propagatedBuildInputs = [
    lsp-tree-sitter
    tree-sitter-tmux
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
  ];
  pythonImportsCheck = [
    "tmux_language_server"
  ];

  meta = with lib; {
    homepage = "https://tmux-language-server.readthedocs.io";
    description = "tmux's language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
