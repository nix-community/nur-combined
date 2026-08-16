{
  sources,
  callPackage,
  lib,
  plumb,
}:
let
  plumb-plugin = plumb.neovim-plugin;
  nvim-treesitter-parsers = callPackage ./nvim-treesitter-parsers {
    inherit plumb;
  };
in
{
  overlay = final: prev: {
    blink-cmp = callPackage ./blink-cmp {
      inherit (prev) blink-cmp;
    };

    iwe-nvim = callPackage ./iwe-nvim {
      source = sources.iwe-nvim;
    };

    plumb-nvim = plumb-plugin;

    nvim-treesitter-parsers = lib.recurseIntoAttrs (
      prev.nvim-treesitter-parsers // nvim-treesitter-parsers
    );
  };

  nvim-treesitter-parser-names = builtins.attrNames nvim-treesitter-parsers;
}
