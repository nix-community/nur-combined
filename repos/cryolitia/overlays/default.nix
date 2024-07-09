{ packages, legacyPackages, ... }:
{
  # Add your overlays here
  nur-cryolitia = (
    final: prev: {
      nur-cryolitia = packages."${prev.system}" // {
        pkgsStatic = legacyPackages."${prev.system}".pkgsStatic;
      };
    }
  );
}
