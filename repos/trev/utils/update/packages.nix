{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  packages =
    pkgs.lib.filterAttrs
      (_: pkg: pkg ? meta && pkg.meta ? platforms && builtins.elem system pkg.meta.platforms)
      (
        import ../../packages {
          inherit system pkgs;
        }
      );

  # Get valid top-level derivations for updating
  derivations = pkgs.lib.filterAttrs (
    _: drv:
    pkgs.lib.isDerivation drv
    # contains a valid updateScript
    && (builtins.hasAttr "updateScript" drv && builtins.isList drv.updateScript)
  ) packages;
in
{
  packages = builtins.mapAttrs (
    _: value: pkgs.lib.concatStringsSep " " value.updateScript
  ) derivations;
}
