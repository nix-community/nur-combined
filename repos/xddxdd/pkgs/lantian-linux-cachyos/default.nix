{
  callPackage,
  lib,
  sources,
  linux,
  ...
}:
let
  mkCachyKernel = callPackage ./mkCachyKernel.nix { inherit sources; };

  batch =
    {
      pnameSuffix,
      version,
      src,
      configVariant,
      ...
    }:
    [
      (mkCachyKernel {
        pnameSuffix = "${pnameSuffix}";
        inherit version src configVariant;
        lto = false;
      })
      (mkCachyKernel {
        pnameSuffix = "${pnameSuffix}-lto";
        inherit version src configVariant;
        lto = true;
      })
    ];

  batches = [
    # # Will setup 6.18 kernel later
    # (batch {
    #   pnameSuffix = "latest";
    #   inherit (linux_latest) version src;
    #   configVariant = "linux-cachyos";
    # })
    (batch {
      pnameSuffix = "lts";
      inherit (linux) version src;
      configVariant = "linux-cachyos-lts";
    })
  ];
in
lib.mapAttrs' (n: v: lib.nameValuePair (lib.removePrefix "linux-cachyos-" n) v) (
  builtins.listToAttrs (lib.flatten batches)
)
