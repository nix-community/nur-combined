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

  platformConfigs = [
    "x86_64-unknown-linux-gnu"
    "x86_64-unknown-linux-musl"
    "aarch64-unknown-linux-gnu"
    "aarch64-unknown-linux-musl"
    "armv7l-unknown-linux-gnueabihf"
    "armv7l-unknown-linux-musleabihf"
    "armv6l-unknown-linux-gnueabihf"
    "armv6l-unknown-linux-musleabihf"
    "x86_64-w64-mingw32"
    "aarch64-w64-mingw32"
    "x86_64-apple-darwin"
    "arm64-apple-darwin"
  ];
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
                      platforms = lib.filterAttrs (n: _: builtins.elem n platformConfigs) attrs;
                    in
                    {
                      forSystems = [ attrs.system ];
                      shortDescription = attrs.meta.description or "";
                      derivationAttrPath = [ ];
                      what = "Package";
                    }
                    // (if isEmpty platforms then { } else { children = recurse (prefix + attrName + ".") platforms; })

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
