{ lib, inputs, self, super, ... }:
with lib;
{
  eachDefaultSystems = f: genAttrs
    [
      "aarch64-linux"
      "x86_64-linux"
    ]
    (system: f (import inputs.nixpkgs { inherit system; overlays = [ super.overlay ]; }));

  collectBlock = name: set:
    let
      recCollectBlock = name: set: foldl
        (acc: n: acc ++ (
          let v = set.${n}; in
          if v ? ${name} then
            [ (nameValuePair n v.${name}) ]
          else
            concatLists (optional (isAttrs v) (recCollectBlock name v))
        ))
        [ ]
        (attrNames set);
    in
    builtins.listToAttrs (recCollectBlock name set);

  mergeAttrList = foldl' mergeAttrs { };

  flattenPackageSet = path: set:
    foldl'
      (acc: name:
        let
          v = set.${name};
          newPath = path ++ [ name ];
        in
        acc // (if isDerivation v then { ${concatStringsSep "-" newPath} = v; }
        else optionalAttrs (isAttrs v) (self.flattenPackageSet newPath v)))
      { }
      (attrNames set);
}
