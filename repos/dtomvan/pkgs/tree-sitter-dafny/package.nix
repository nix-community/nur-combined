{
  fetchFromGitHub,
  tree-sitter,
}:

tree-sitter.buildGrammar {
  language = "dafny";
  version = "0-unstable-2024-02-28";

  src = fetchFromGitHub {
    owner = "kiryls";
    repo = "tree-sitter-dafny";
    rev = "b8cdcd77365b8142f0dffd352dbc8b9e6090293d";
    hash = "sha256-kje9lcnb533npr0QIxRQQ6ZZlm3GJ9LNVYLSKypSF98=";
  };
}
