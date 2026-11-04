{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    {
      legacyPackages = builtins.intersectAttrs (lib.genAttrs [
        "deviceTrees"
      ] (_: null)) pkgs;
    };
}
