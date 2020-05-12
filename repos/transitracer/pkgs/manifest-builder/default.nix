{ pkgs, lib, runCommand, writeText, nix
, selfCall ? false
}:

let
  manifest-nix = packages:
    let
      pkgToSpec = pkg: with pkg; {
        inherit meta system drvPath;
        outputs = meta.outputsToInstall;
      };
      spec = map pkgToSpec packages;
      jsonSpec = writeText "manifestSpec.json" (builtins.toJSON spec);
    in runCommand "manifest.nix" {} ''
    # Using the `nix` derivation here seems to pull in a lot of
    # dependencies, but without recursive nix it's the best I can do.

    ${nix}/bin/nix-instantiate --strict --eval \
      -E 'with import "${pkgs.path}" {}; (callPackage ${./.} { selfCall = true; }) "${jsonSpec}"' \
      > $out
    '';

  builder = jsonSpec:
    let
      spec = lib.trivial.importJSON jsonSpec;
      specToManifest = pkgSpec:
        let
          pkg = import pkgSpec.drvPath;
        in (with pkg; {
          inherit name outPath type;
        }) // (lib.attrsets.genAttrs pkgSpec.outputs (name: {
          inherit (pkg.${name}) outPath;
        })) // (builtins.removeAttrs pkgSpec [ "drvPath" ]);
    in map specToManifest spec;
in if selfCall
   then builder
   else manifest-nix
