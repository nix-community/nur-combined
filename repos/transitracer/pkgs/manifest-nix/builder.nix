{ lib }:

jsonSpec:

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
in map specToManifest spec
