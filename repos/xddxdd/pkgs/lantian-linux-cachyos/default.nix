{
  mode ? null,
  callPackage,
  lib,
  sources,
  linux_6_12,
  linux_latest,
  ...
}:
let
  mkCachyKernel = callPackage ./mkCachyKernel.nix { inherit mode sources; };

  batch =
    {
      prefix,
      version,
      src,
      configVariant,
      ...
    }:
    [
      (mkCachyKernel {
        pname = "${prefix}";
        inherit version src configVariant;
        lto = false;
      })
      (mkCachyKernel {
        pname = "${prefix}-lto";
        inherit version src configVariant;
        lto = true;
      })
    ];

  batches = [
    (batch {
      prefix = "latest";
      inherit (linux_latest) version src;
      configVariant = "linux-cachyos";
    })
    (batch {
      prefix = "lts";
      inherit (linux_6_12) version src;
      configVariant = "linux-cachyos";
    })
    (batch {
      prefix = "v6_12";
      inherit (linux_6_12) version src;
      configVariant = "linux-cachyos";
    })
  ];

  batchesAttrs = builtins.listToAttrs (lib.flatten batches);
in
if mode == "ci" then
  lib.filterAttrs (n: _v: lib.hasSuffix "configfile" n) batchesAttrs
else if mode == "nur" then
  lib.filterAttrs (n: _v: !lib.hasSuffix "configfile" n) batchesAttrs
else
  batchesAttrs
