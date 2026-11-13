{
  description = "sylr's NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      # Only the packages that support each system, so a darwin-only package
      # doesn't appear (and fail `nix flake check`) under the linux systems.
      packages = forAllSystems (system:
        let platform = nixpkgs.lib.systems.elaborate system;
        in nixpkgs.lib.filterAttrs
          (_: v: nixpkgs.lib.isDerivation v && nixpkgs.lib.meta.availableOn platform v)
          self.legacyPackages.${system});
      nixosModules = import ./nixos-modules;
      # homeModules = import ./home-modules;
      # darwinModules = import ./darwin-modules;
      # flakeModules = import ./flake-modules;
    };
}
