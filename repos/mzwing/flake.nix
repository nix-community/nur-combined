{
  description = "Mzwing's NUR packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
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
    nixosModules = import ./nixos-modules;
    homeModules = import ./home-modules;
    # darwinModules = import ./darwin-modules;
    # flakeModules = import ./flake-modules;
  };
}
