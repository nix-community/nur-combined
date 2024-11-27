{
  mySources,
  python3,
  lib,
  lsp-tree-sitter,
  tree-sitter-bash,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.termux-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    lsp-tree-sitter
    tree-sitter-bash
    platformdirs
    fqdn
    rfc3987
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
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
