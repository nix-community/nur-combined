{ ... }:
{
  perSystem =
    { plainConfig, ... }:
    {
      packages.units = plainConfig.config.vacu.units.finalPackage;
    };
}
