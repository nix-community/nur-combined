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

  crossPlatforms = [
    "x86_64-linux-gnu"
    "x86_64-linux-musl"
    "aarch64-linux-gnu"
    "aarch64-linux-musl"
    "armv7l-linux-gnu"
    "armv7l-linux-musl"
    "armv6l-linux-gnu"
    "armv6l-linux-musl"
  ];
in
{
  version = 1;
  doc = ''
    The `appimages` flake output contains packages that have been bundled into AppImages.
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
                      platforms = lib.filterAttrs (n: _: builtins.elem n crossPlatforms) attrs;
                    in
                    {
                      forSystems = [ attrs.system ];
                      shortDescription = attrs.meta.description or "";
                      derivationAttrPath = [ ];
                      what = "AppImage";
                    }
                    // (if isSingle platforms then { } else { children = recurse (prefix + attrName + ".") platforms; })

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
          assert imagesForSystem.type or null != "derivation";
          recurse (systemType + ".") imagesForSystem;
      }) output
    );
}
