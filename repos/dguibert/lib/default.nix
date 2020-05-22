{ pkgs }:

with pkgs.lib; pkgs.lib // rec {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  compose = list: fix (builtins.foldl' (flip extends) (self: pkgs) list);

  composeOverlays = foldl' composeExtensions (self: super: {});

  makeExtensible' = pkgs: list: builtins.foldl' /*op nul list*/
    (o: f: o.extend f) (makeExtensible (self: pkgs)) list;

}

