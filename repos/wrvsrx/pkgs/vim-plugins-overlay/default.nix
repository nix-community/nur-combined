{ sources, callPackage }:
final: prev: {
  iwe-nvim = callPackage ./iwe-nvim {
    source = sources.iwe-nvim;
  };
}
