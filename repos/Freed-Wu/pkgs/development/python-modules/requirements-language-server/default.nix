{
  mySources,
  python3,
  lib,
  tree-sitter-requirements,
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.requirements-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.11";
  propagatedBuildInputs = [
    pip
    aiohttp
    platformdirs
    lsp-tree-sitter
    tree-sitter-requirements
  ];
  nativeBuildInputs = [
    setuptools-generate
    setuptools-scm
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
