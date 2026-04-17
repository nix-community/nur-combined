{
  lib,
  helpers,
}:
let
  platformConfigs = [
    "x86_64-unknown-linux-gnu"
    "x86_64-unknown-linux-musl"
    "aarch64-unknown-linux-gnu"
    "aarch64-unknown-linux-musl"
    "armv7l-unknown-linux-gnueabihf"
    "armv7l-unknown-linux-musleabihf"
    "armv6l-unknown-linux-gnueabihf"
    "armv6l-unknown-linux-musleabihf"
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
    helpers.mkChildren (
      builtins.mapAttrs (systemType: imagesForSystem: {
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
                      platforms = lib.filterAttrs (n: _: builtins.elem n platformConfigs) attrs;
                    in
                    {
                      forSystems = [ attrs.system ];
                      shortDescription = attrs.meta.description or "";
                      derivationAttrPath = [ ];
                      what = "AppImage";
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
          assert imagesForSystem.type or null != "derivation";
          recurse (systemType + ".") imagesForSystem;
      }) output
    );
}
