{
  python3,
  model2vec, vicinity, bm25s, tree-sitter-language-pack,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "semble";
  version = "v0.1.10";
  sha256 = "sha256-KGCXzsL2OsCYcnAEcs66HCNCKVJdFDOE6EEnljlKohk=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  patches = [ ./01-remove-version-restriction-on-language-pack.patch ];

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
  ];
}