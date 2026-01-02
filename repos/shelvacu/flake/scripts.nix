{ vaculib, vacuRoot, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = builtins.mapAttrs (_: fn: pkgs.callPackage fn { }) (
        import /${vacuRoot}/scripts { inherit vaculib; }
      );
    };
}
