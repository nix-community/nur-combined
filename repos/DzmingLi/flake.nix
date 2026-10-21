{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, emacs-overlay }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            emacs-overlay.overlays.package
            self.overlays.default
          ];
        };
      });
      overlays.default = import ./overlay.nix;
      packages = forAllSystems (system:
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          update = let
            pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          in pkgs.callPackage ./scripts/update.nix {
            packages = import ./default.nix { inherit pkgs; };
          };
        });
      homeManagerModules = (import ./modules).home-manager;
      nixosModules = (import ./modules).nixos;
      checks.x86_64-linux.update-transactions = self.packages.x86_64-linux.update.tests.transactions;
    };
}
