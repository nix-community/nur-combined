{
  sources,
  callPackage,
  plumb,
}:
final: prev: {
  iwe-nvim = callPackage ./iwe-nvim {
    source = sources.iwe-nvim;
  };

  nvim-treesitter-parsers = callPackage ./nvim-treesitter-parsers {
    inherit (prev) nvim-treesitter-parsers;
    inherit plumb;
  };
}
