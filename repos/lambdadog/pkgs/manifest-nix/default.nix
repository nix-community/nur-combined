{ pkgs, runCommand, writeText, nix }:

packages:

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
    -E 'with import "${pkgs.path}" {}; (callPackage ${./builder.nix} {}) "${jsonSpec}"' \
    > $out
''
