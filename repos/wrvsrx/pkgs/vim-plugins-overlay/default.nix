{
  sources,
  callPackage,
  plumb,
}:
let
  plumb-plugin = plumb.neovim-plugin;
in
final: prev: {
  blink-cmp = callPackage ./blink-cmp {
    inherit (prev) blink-cmp;
  };

  iwe-nvim = callPackage ./iwe-nvim {
    source = sources.iwe-nvim;
  };

  plumb-nvim = plumb-plugin;

  nvim-treesitter-parsers = callPackage ./nvim-treesitter-parsers {
    inherit (prev) nvim-treesitter-parsers;
    inherit plumb;
  };
}
