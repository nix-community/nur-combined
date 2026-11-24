{
  inputs,
  lib',
  ...
}:

{
  perSystem =
    { system, ... }:
    {
      # Top-level module arguments are not visible in `perSystem`.
      _module.args.lib' = lib';
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};
    };
}
