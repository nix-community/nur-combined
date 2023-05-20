let
  buildModuleTree' = depth: vs:
    let
      ys = builtins.sort (a: b: builtins.length a.path < builtins.length b.path) vs;
      ys' = builtins.groupBy (v: builtins.elemAt v.path depth) (builtins.filter (v: builtins.length v.path > depth) ys);
      go' = _: xs:
        let
          repr = builtins.head xs;
        in
        if builtins.length repr.path == depth + 1
        then repr.content
        else buildModuleTree' (depth + 1) xs;
    in builtins.mapAttrs go' ys';

  buildModuleTree = buildModuleTree' 0;

  modules = let
    mkSimplePathDotNix = path:
      {
        inherit path;
        content = ./. + "/${builtins.concatStringsSep "/" path}.nix";
      };
  in [ ];
in buildModuleTree modules
