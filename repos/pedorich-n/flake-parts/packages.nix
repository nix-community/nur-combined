{
  perSystem =
    {
      config,
      lib,
      ...
    }:
    {
      packages = (lib.filterAttrs (_: v: lib.isDerivation v) config.legacyPackages);
    };
}
