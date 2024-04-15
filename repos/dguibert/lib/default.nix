final: prev:
with prev; let
  fix = f: let fixpoint = f fixpoint; in fixpoint;
  withOverride = overrides: f: self:
    f self
    // (
      if builtins.isFunction overrides
      then overrides self
      else overrides
    );

  self = with self; {
    # http://r6.ca/blog/20140422T142911Z.html
    virtual = f: fix f // {_override = overrides: virtual (withOverride overrides f);}; #
    # hexint = x: hexvals.${toLower x};
    compose = list: fix (builtins.foldl' (flip extends) (self: pkgs) list);

    composeOverlays = foldl' composeExtensions (self: super: {});

    makeExtensible' = pkgs: list:
      builtins.foldl'
      /*
      op nul list
      */
      (o: f: o.extend f) (makeExtensible (self: pkgs))
      list;

    upgradeOverride = package: overrides: let
      upgraded = package.overrideAttrs overrides;
    in (upgradeReplace package upgraded);

    upgradeReplace = package: upgraded: let
      upgradedVersion = (builtins.parseDrvName upgraded.name).version;
      originalVersion = (builtins.parseDrvName package.name).version;

      isDowngrade = (builtins.compareVersions upgradedVersion originalVersion) == -1;

      warn =
        builtins.trace
        "Warning: ${package.name} downgraded by overlay with ${upgraded.name}.";
      pass = x: x;
    in
      (
        if isDowngrade
        then warn
        else pass
      )
      upgraded;

    find-tarballs = drv:
      import ./find-tarballs.nix {
        lib = prev;
        inherit drv;
      };

    recursiveMerge = attrList: let
      f = attrPath:
        zipAttrsWith (
          n: values:
            if tail values == []
            then head values
            else if all isList values
            then unique (concatLists values)
            else if all isAttrs values
            then f (attrPath ++ [n]) values
            else last values
        );
    in
      f [] attrList;
  };
in
  self
