{
  pkgs,
  sources,
  ...
}: let
  buildGrammar = language:
    pkgs.tree-sitter.buildGrammar {
      inherit language;
      inherit (sources."tree-sitter-${language}") src;
      version = sources."tree-sitter-${language}".date;
    };
in {
  tree-sitter-hypr = buildGrammar "hypr";
}
