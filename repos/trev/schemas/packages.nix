{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  schemas ? { },
}:
let
  isEmpty = set: builtins.attrNames set == [ ];
in
{
  version = 1;
  doc = ''
    The `packages` flake output contains packages that can be added to a shell using `nix shell`.
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
    schemas.lib.mkChildren (
      builtins.mapAttrs (systemType: packagesForSystem: {
        forSystems = [ systemType ];
        children =
          let
            recurse =
              prefix: attrs:
              builtins.mapAttrs (
                attrName: attrs:

                # Necessary to deal with `AAAAAASomeThingsFailToEvaluate` etc. in Nixpkgs.
                schemas.lib.try (
                  if pkgs.lib.isDerivation attrs then
                    let
                      crosses = pkgs.lib.filterAttrs (n: _: builtins.elem n (attrs.meta.platforms or [ ])) attrs;
                    in
                    {
                      forSystems = [ attrs.system ];
                      shortDescription = attrs.meta.description or "";
                      derivationAttrPath = [ ];
                      what = "package";
                    }
                    // (if isEmpty crosses then { } else { children = recurse (prefix + attrName + ".") crosses; })

                  else

                  # Recurse at the first and second levels, or if the recurseForDerivations attribute if set.
                  if attrs.recurseForDerivations or false then
                    {
                      children = recurse (prefix + attrName + ".") attrs;
                    }
                  else
                    {
                      what = "unknown";
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
