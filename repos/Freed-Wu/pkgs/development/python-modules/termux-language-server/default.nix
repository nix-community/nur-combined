{
  mySources,
  python3,
  lib,
  lsp-tree-sitter,
}:

with python3.pkgs;

buildPythonPackage {
  inherit (mySources.termux-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    lsp-tree-sitter
    tree-sitter-grammars.tree-sitter-bash
    fqdn
    rfc3987
  ];
  nativeBuildInputs = [
    uv-build
  ];
  pythonImportsCheck = [
    "termux_language_server"
  ];

  meta = with lib; {
    homepage = "https://termux-language-server.readthedocs.io";
    description = "termux build.sh language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
