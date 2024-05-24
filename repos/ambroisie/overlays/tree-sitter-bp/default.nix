self: prev:
let
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-bp = {
        src = self.fetchFromGitHub {
          owner = "ambroisie";
          repo = "tree-sitter-bp";
          rev = "v0.4.0";
          hash = "sha256-h9T8tfS2K85N9NLwYj6tu2MHPj4YyG/UBYoezfWuEyI=";
        };
      };
    };
  };
in
{
  inherit (tree-sitter.passthru.builtGrammars) tree-sitter-bp;
}
