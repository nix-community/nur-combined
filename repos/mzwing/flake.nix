{
  description = "Mzwing's NUR packages";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # internal/gomod2nix.nix reads this pin from flake.lock, so default.nix evaluates without flakes.
    gomod2nix = {
      url = "github:mzwing/gomod2nix";
      flake = false;
    };
    nix-repin = {
      url = "github:so1ve/nix-repin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nix-repin,
    ...
  }: let
    supportedSystems = import ./internal/systems.nix;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    legacyPackages =
      forAllSystems (system:
        import ./default.nix {pkgs = nixpkgs.legacyPackages.${system};});
    packages = forAllSystems (system: let
      platform = nixpkgs.legacyPackages.${system}.stdenv.hostPlatform;
    in
      nixpkgs.lib.filterAttrs
      (_: package: nixpkgs.lib.isDerivation package && nixpkgs.lib.meta.availableOn platform package)
      self.legacyPackages.${system});
    apps = forAllSystems (system:
      import ./scripts {
        pkgs = nixpkgs.legacyPackages.${system};
      }
      # nix-repin only builds for Linux.
      // nixpkgs.lib.optionalAttrs (nix-repin.apps ? ${system}) {
        update-sources = nix-repin.apps.${system}.default;
      });
    nixosModules = import ./nixos-modules;
    homeModules = import ./home-modules;
    darwinModules = import ./darwin-modules;
    # flakeModules = import ./flake-modules;
  };
}
