{ inputs, ... }: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
    ./ci.nix
  ];

  perSystem = { config, pkgs, ... }: {
    legacyPackages = import ../default.nix { inherit pkgs; };
    overlayAttrs = config.legacyPackages;
    packages = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) config.legacyPackages;
  };

  flake.lib = import ../lib;
}
