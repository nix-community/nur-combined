{ inputs, ... }:

{
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.self.overlays.default
          (import ../overlays/omniorb.nix)
          (import ../overlays/osg.nix)
          (import ../overlays/pinocchio.nix)
          (import ../overlays/python.nix)
        ];
        config = { };
      };

      overlayAttrs = config.packages;
    };
}
