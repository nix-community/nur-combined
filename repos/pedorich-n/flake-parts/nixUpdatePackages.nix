{
  withSystem,
  lib,
  ...
}:
{
  flake.nixUpdatePackages = withSystem "x86_64-linux" (
    {
      config,
      ...
    }:
    lib.attrNames (lib.filterAttrs (_name: pkg: pkg ? passthru.updateScript) config.packages)
  );
}
