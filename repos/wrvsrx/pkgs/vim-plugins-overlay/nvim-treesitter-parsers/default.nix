{
  lib,
  neovimUtils,
  nvim-treesitter-parsers,
  plumb,
  runCommandLocal,
  vimUtils,
}:

let
  grammar = plumb.tree-sitter-plumb;
  generatedSource = grammar.generatedSource;

  # Mirrors vimPlugins.nvim-treesitter.buildQueries from nixpkgs. That helper
  # only reads nvim-treesitter's runtime, so use the grammar's own queries here.
  query = vimUtils.toVimPlugin (
    runCommandLocal "nvim-treesitter-queries-plumb"
      {
        passthru = {
          language = "plumb";
          isTreesitterQuery = true;
        };
        meta.description = "Queries for plumb";
      }
      ''
        mkdir -p "$out/queries"
        ln -s "${generatedSource}/queries" "$out/queries/plumb"
      ''
  );

  parser = (neovimUtils.grammarToPlugin grammar).overrideAttrs (old: {
    installQueries = false;
    passthru = old.passthru or { } // {
      associatedQuery = query;
    };
  });
in
lib.recurseIntoAttrs (
  nvim-treesitter-parsers
  // {
    plumb = parser;
  }
)
