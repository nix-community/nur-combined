{ pkgs, selfLib }:

pkgs.callPackage ./top-level/all-packages.nix {
  lib = pkgs.lib // (selfLib { inherit pkgs; inherit (pkgs) lib; });

  # ok, so:
  newScope = let
    inherit (pkgs) lib;
    # what if instantiated pkgs was a scope?
    pkgsScope = lib.makeScope pkgs.newScope (_: pkgs);
    # and what if we overrode it for inter-NUR python use?
    overriddenPkgsNewScope = overriddenPkgsScope.newScope;

    overriddenPkgsScope = pkgsScope
      .overrideScope' pythonScopeOverrides;

    pythonScopeOverrides = let
      # (this could definitely be better)
      #
      # attrs :: [ "python2" "python37" "python3" "python" ];
      # (decreasing order of specificity)
      setupPyAttrs = let
        updateFroml' = lib.foldl' (acc: x: acc // x);
        updatel' = updateFroml' { };
        concatMapAttrs' = f: set: lib.listToAttrs
          (lib.concatMap (attr: f attr set.${attr}) (lib.attrNames set));
        nvPair = lib.nameValuePair;
      in self: super: attrs: let
          attrs' = lib.zipAttrs (builtins.map (attr: {
            # unsafeDiscardStringContext is fine because we ditch the path
            # afterwards. The name is just for sorting, never later evaluation.
            ${builtins.unsafeDiscardStringContext super.${attr}.drvPath} = attr;
          }) attrs);
        in concatMapAttrs' (_: attrs: let
            ps = lib.imap0
              (i: attr: let prevAttr = lib.elemAt attrs (i - 1); in
              if i == 0 then
                nvPair attr self.pythonInterpreters.${attr}
              else
                nvPair attr self.${prevAttr})
              attrs;
          in lib.concatMap ({ name, value }: [
            (nvPair name value)
            (nvPair (name + "Full") (self.${name}.override{x11Support=true;}))
            (nvPair (name + "Packages") self.${name}.pkgs)
          ]) ps) attrs';
    in self: super: {
      # so, this is cursed
      # we're going to override the root pythonInterpreters expression so
      # deriving other overrides is easier
      # (and we can share a dream of universal python overrides)
      pythonInterpreters = super.pythonInterpreters.override (o: {
        # we now are overriding the pkgs it uses in `with pkgs;` to access
        # callPackage
        pkgs = o.pkgs // {
          # which is pretty much only called to deal with
          # top-level/python-packages, so we hijack it for ourselves
          callPackage = fn: args: o.pkgs.callPackage fn (let
            # snatch away packageOverrides and force our own on
            packageOverrides = pySelf: pySuper:
              # walk backwards through the infinite recursion of lib.fix'
              pySuper.__extends__ or
                # until we can insert our scope-y selves at the root
                # and take advantage of the specific way python-packages seals
                # itself with overrides up
                (let pyScope = lib.makeScope self.newScope (self: pySuper // {
                  # we reset callPackage for anyone inside to something sane
                  # and under our scope's control
                  inherit (self) callPackage;
                }); in if args ? packageOverrides then
                  # and if someone specified some overrides, apply those in
                  # the manner we desire now
                  pyScope.overrideScope' args.packageOverrides
                else
                  pyScope);

            # of course, only specify if fn can take it
            f = if lib.isFunction fn then fn else import fn;

            # (woo you can tell it's still good because we reimplemented a bit
            # of lib.callPackageWith just now)

            in if (lib.functionArgs f) ? packageOverrides then
              args // { inherit packageOverrides; }
            else
              args);
        };
      });
    } // (setupPyAttrs self super [
      "python37"
      "python36"
      "python3"
      "python2"
      "python"
    ]);
  in overriddenPkgsNewScope;
}
