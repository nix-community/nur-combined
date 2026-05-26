{
  lib,
  python3,
  model2vec, vicinity, bm25s, tree-sitter-language-pack, pathspec,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "semble";
  version = "v0.2.0";
  sha256 = "sha256-daFdBd9yM8AjnSi56n5AS++hhe3VMTg1bOP9rXyZHDo=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  meta = {
    description = "Fast and Accurate Code Search for Agents. Uses ~98% fewer tokens than grep+read";
    homepage = "https://github.com/MinishLab/semble";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  pyproject = true;

  build-system = with python.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python.pkgs; [
    model2vec
    vicinity
    numpy
    bm25s
    pathspec
    tree-sitter
    tree-sitter-language-pack

    # For the MCP server
    mcp
    watchfiles
  ];
}