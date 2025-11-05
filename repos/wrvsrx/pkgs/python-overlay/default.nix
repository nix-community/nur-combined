{ sources }:
final: prev: {
  # we can only use `final.callPackage` here if we want the overlay works well
  autobean-format = final.callPackage ./autobean-format {
    source = sources.autobean-format;
    inherit (final) autobean-refactor;
  };
  autobean-refactor = final.callPackage ./autobean-refactor { source = sources.autobean-refactor; };
  jraph = final.callPackage ./jraph { source = sources.jraph; };
  jax-md = final.callPackage ./jax-md {
    source = sources.jax-md;
    inherit (final) e3nn-jax jraph;
  };
  e3nn-jax = final.callPackage ./e3nn-jax { source = sources.e3nn-jax; };
  keymap-drawer = final.callPackage ./keymap-drawer {
    source = sources.keymap-drawer;
    inherit (final) tree-sitter-devicetree;
  };
  tree-sitter-devicetree = final.callPackage ./tree-sitter-devicetree {
    source = sources.tree-sitter-devicetree;
  };
}
