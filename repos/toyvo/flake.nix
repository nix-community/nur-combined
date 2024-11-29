{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    "nixos-24.05".url = "github:NixOS/nixpkgs/nixos-24.05";
  };
  outputs =
    { self, nixpkgs-unstable, ... }:
    let
      lib = nixpkgs-unstable.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs-unstable { inherit system; };
        }
      );
      packages = forAllSystems (
        system: lib.filterAttrs (_: v: lib.isDerivation v) self.legacyPackages.${system}
      );
      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs-unstable { inherit system; };
        in
        pkgs.nixfmt-rfc-style
      );
      nixosModules = import ./modules;
    };
}
