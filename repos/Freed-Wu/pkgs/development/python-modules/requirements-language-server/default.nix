{
  mySources,
  python3,
  lib,
  tree-sitter-requirements,
  lsp-tree-sitter,
}:

with python3.pkgs;

buildPythonPackage {
  inherit (mySources.requirements-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.11";
  propagatedBuildInputs = [
    pip
    aiohttp
    platformdirs
    lsp-tree-sitter
    tree-sitter-requirements
    marisa-trie
    jinja2
  ];
  nativeBuildInputs = [
    uv-build
  ];
  pythonImportsCheck = [
    "requirements_language_server"
  ];

  meta = with lib; {
    homepage = "https://requirements-language-server.readthedocs.io";
    description = "requirements.txt language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
