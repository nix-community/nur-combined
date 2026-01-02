{ ... }:
{
  perSystem =
    { common, ... }:
    {
      legacyPackages = {
        pkgs = common.pkgs;
        stable = common.pkgsStable;
        unstable = common.pkgsUnstable;
      };
    };
}
