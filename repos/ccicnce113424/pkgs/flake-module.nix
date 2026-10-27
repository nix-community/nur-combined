{
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      packageSet = import ./. { inherit pkgs; };
    in
    {
      packages = lib.removeAttrs packageSet [
        "callPackage"
        "newScope"
        "overrideScope"
        "packages"
        "nixosModules"
      ];
      overlayAttrs = config.packages;
    };

  flake = {
    # Overlay only, for consumers that compose it themselves.
    nixosModules.overlay = {
      nixpkgs.overlays = [ self.overlays.default ];
    };

    # Backwards-compatible default: the service modules plus the overlay.
    # Consumers that already apply `overlays.default` to their own `pkgs`
    # should import `nixosModules.modules` instead: adding `nixpkgs.overlays`
    # to an already constructed `pkgs` makes the nixpkgs module re-import
    # nixpkgs in full
    # (`cfg.pkgs.appendOverlays cfg.overlays` in nixos/modules/misc/nixpkgs.nix).
    nixosModules.default = {
      imports = [
        self.nixosModules.modules
        self.nixosModules.overlay
      ];
    };
  };
}
