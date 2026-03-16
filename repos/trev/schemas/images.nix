{
  lib,
}:
let
  isSingle = set: builtins.length (builtins.attrNames set) <= 1;
  mkChildren = children: { inherit children; };
  try =
    e: default:
    let
      res = builtins.tryEval e;
    in
    if res.success then res.value else default;

  architectures = [
    "amd64"
    "arm64"
    "arm"
  ];
in
{
  version = 1;
  doc = ''
    The `images` flake output contains derivations that build valid Open Container Initiative images.
  '';
  roles = {
    nix-build = { };
  };
  appendSystem = true;
  defaultAttrPath = [ "default" ];
  inventory =
    output:
    mkChildren (
      builtins.mapAttrs (systemType: imagesForSystem: {
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
                      archs = lib.filterAttrs (n: _: builtins.elem n architectures) attrs;
                    in
                    {
                      forSystems = [ attrs.system ];
                      shortDescription = attrs.meta.description or "";
                      derivationAttrPath = [ ];
                      what = "image";
                    }
                    // (if isSingle archs then { } else { children = recurse (prefix + attrName + ".") archs; })

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
          assert imagesForSystem.type or null != "derivation";
          recurse (systemType + ".") imagesForSystem;
      }) output
    );
}
