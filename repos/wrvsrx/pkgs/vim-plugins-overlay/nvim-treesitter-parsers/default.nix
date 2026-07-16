{
  lib,
  neovimUtils,
  nodejs,
  nvim-treesitter-parsers,
  runCommandLocal,
  stdenvNoCC,
  tree-sitter,
  tree-sitter-plumb-source,
  vimUtils,
}:

let
  inherit (tree-sitter-plumb-source) version;
  src = tree-sitter-plumb-source.src + "/tree-sitter-plumb";

  generatedSource = stdenvNoCC.mkDerivation {
    pname = "tree-sitter-plumb-src";
    inherit version src;

    nativeBuildInputs = [
      nodejs
      tree-sitter
    ];

    buildPhase = ''
      runHook preBuild
      tree-sitter generate
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r . "$out"
      runHook postInstall
    '';
  };

  grammar = tree-sitter.buildGrammar {
    language = "plumb";
    inherit version;
    src = generatedSource;

    passthru.generatedSource = generatedSource;

    meta = {
      description = "Tree-sitter grammar for plumb";
      homepage = "https://github.com/wrvsrx/plumb/tree/${tree-sitter-plumb-source.version}/tree-sitter-plumb";
      license = lib.licenses.mit;
    };
  };

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
