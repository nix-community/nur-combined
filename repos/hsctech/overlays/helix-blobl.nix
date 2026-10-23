final: prev: {
  helix-blobl = prev.callPackage ../pkgs/helix-blobl { };
  tree-sitter-bloblang = prev.callPackage ../pkgs/tree-sitter-bloblang { };

  # The fork is a superset of upstream helix.
  helix = final.helix-blobl;
}
