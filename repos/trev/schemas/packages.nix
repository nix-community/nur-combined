{
  lib,
  helpers,
}:
{
  version = 1;
  doc = ''
    The `packages` flake output contains packaged applications for nix.
  '';
  roles = {
    nix-build = { };
    nix-run = { };
    nix-develop = { };
    nix-search = { };
  };
  appendSystem = true;
  defaultAttrPath = [ "default" ];
  inventory =
    output:
    helpers.mkChildren (
      builtins.mapAttrs (systemType: packagesForSystem: {
        forSystems = [ systemType ];
        children =
          let
            recurse =
              prefix: attrs:
              builtins.mapAttrs (
                attrName: attrs:

                # Necessary to deal with `AAAAAASomeThingsFailToEvaluate` etc. in Nixpkgs.
                helpers.try (
                  if lib.isDerivation attrs then
                    let
                      platforms = lib.filterAttrs (n: _: builtins.elem n helpers.platforms) attrs;
                    in
                    {
                      forSystems = [ attrs.system ];
                      shortDescription = attrs.meta.description or "";
                      what = "Package";
                      derivationAttrPath = [ ];
                    }
                    // (
                      if helpers.isSingle platforms then
                        { }
                      else
                        { children = recurse (prefix + attrName + ".") platforms; }
                    )

                  else

                  # Recurse at the first and second levels, or if the recurseForDerivations attribute if set.
                  if attrs.recurseForDerivations or false then
                    {
                      children = recurse (prefix + attrName + ".") attrs;
                    }
                  else
                    {
                      what = "Unknown";
                    }

                ) (throw "failed")
              ) attrs;
          in
          # The top-level cannot be a derivation.
          assert packagesForSystem.type or null != "derivation";
          recurse (systemType + ".") packagesForSystem;
      }) output
    );
}
