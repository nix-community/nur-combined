self: super:

let filterSet =
      (f: g: s: builtins.listToAttrs
        (map
          (n: { name = n; value = builtins.getAttr n s; })
          (builtins.filter
            (n: f n && g (builtins.getAttr n s))
            (builtins.attrNames s)
          )
        )
      );
in filterSet
     (n: !(n=="lib"||n=="overlays"||n=="modules"||n=="darwin-modules"))
     (p: true)
     (import ./default.nix { pkgs = super; })

