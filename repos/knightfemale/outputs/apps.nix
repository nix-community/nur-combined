{
  perSystem =
    {
      lib,
      self',
      ...
    }:
    {
      apps = lib.mapAttrs (name: pkg: {
        type = "app";
        meta.description = pkg.meta.description;
        program = lib.getExe pkg;
      }) (lib.filterAttrs (_: pkg: (pkg.meta.mainProgram or null) != null) self'.packages);
    };
}
