{
  lib,
}:
let
  isEmpty = set: builtins.attrNames set == [ ];
  mkChildren = children: { inherit children; };
  try =
    e: default:
    let
      res = builtins.tryEval e;
    in
    if res.success then res.value else default;
in
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
    mkChildren (
      builtins.mapAttrs (systemType: packagesForSystem: {
        forSystems = [ systemType ];
        children =
          let
            recurse =
              prefix: attrs:
              builtins.mapAttrs (
                attrName: attrs:

                # Necessary to deal with `AAAAAASomeThingsFailToEvaluate` etc. in Nixpkgs.
                try (
                  if lib.isDerivation attrs then
                    let
                      crosses = lib.filterAttrs (n: _: builtins.elem n (attrs.meta.platforms or [ ])) attrs;
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
