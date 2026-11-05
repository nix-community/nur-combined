{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    {
      legacyPackages = lib.filterAttrs (_: v: v != null) {
        inherit (pkgs)
          deviceTrees
          ;
      };
    };
}
