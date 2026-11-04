{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.overlays = {
    default = import ./_overlays/default.nix { inherit lib; };
  };

  perSystem =
    {
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ config.flake.overlays.default ];
      };
    };
}
