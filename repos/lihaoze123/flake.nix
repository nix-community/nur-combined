{
  description = "lihaoze123's NUR packages";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  # Maintenance pins for sync-project-inputs.py. Runtime packages and modules
  # use local Nix expressions and the caller's pkgs, never these Flake outputs.
  inputs.dms-xhup = {
    url = "github:lihaoze123/dms-xhup/3323ff83dcf34f569f9c433234a2d20e3c0daec1";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.computer-use.url = "github:lihaoze123/niri-computer-use/bd6e39f3822ab5e14158def4817f89725064061d";
  inputs.edunet.url = "github:lihaoze123/hhu-edunet-cli/cd4b7d4d12be160fc8c1aee777adf60267b759a7";
  inputs.gxfp5130Chicago = {
    url = "github:lihaoze123/gxfp5130-chicago/fa78a635b5e4b2f20bf03178a0cdce53bc9318aa";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      legacyPackages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in import ./default.nix { inherit pkgs; });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs
        (_: value: nixpkgs.lib.isDerivation value)
        self.legacyPackages.${system});
      ciMetadata = forAllSystems (system: import ./ci-private.nix {
        inherit system;
        inherit (nixpkgs) lib;
        packages = self.packages.${system};
      });
      nixosModules = import ./nixos-modules;
      overlays = import ./overlays;
      lib.cacheConfig = import ./lib/cache-config.nix;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
