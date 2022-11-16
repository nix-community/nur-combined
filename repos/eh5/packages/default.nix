rec {
  packages = import ./packages.nix;

  legacyPackages = pkgs: import ./packages.nix { inherit pkgs; filterByPlatform = false; };

  overlays.default = final: prev: legacyPackages prev;
}
