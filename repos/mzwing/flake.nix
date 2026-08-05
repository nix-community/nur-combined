{
  description = "Mzwing's NUR packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # Used to build the Rust packages in two layers (dependencies vs. the
  # package itself) so dependency builds are cached across version bumps.
  inputs.crane.url = "github:ipetkov/crane";
  outputs = {
    self,
    nixpkgs,
    crane,
  }: let
    supportedSystems = import ./internal/systems.nix;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    legacyPackages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in
      import ./default.nix {
        inherit pkgs;
        craneLib = crane.mkLib pkgs;
      });
    packages = forAllSystems (system: let
      platform = nixpkgs.legacyPackages.${system}.stdenv.hostPlatform;
    in
      nixpkgs.lib.filterAttrs
      (_: package: nixpkgs.lib.isDerivation package && nixpkgs.lib.meta.availableOn platform package)
      self.legacyPackages.${system});
    apps.x86_64-linux = import ./scripts {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };
    nixosModules = import ./nixos-modules {lib = nixpkgs.lib;};
    homeModules = import ./home-modules {lib = nixpkgs.lib;};
    darwinModules = import ./darwin-modules {lib = nixpkgs.lib;};
    # flakeModules = import ./flake-modules;
  };
}
